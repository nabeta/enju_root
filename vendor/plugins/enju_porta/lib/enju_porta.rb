module EnjuPorta
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_porta
      include EnjuPorta::InstanceMethods
    end

    def import_isbn(isbn)
      isbn = ISBN_Tools.cleanup(isbn)
      raise 'invalid ISBN' unless ISBN_Tools.is_valid?(isbn)

      if manifestation = self.find(:first, :conditions => {:isbn => isbn})
        raise 'already imported'
      end

      xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
      doc = LibXML::XML::Document.string(xml).root
      if doc.find_first('//openSearch:totalResults').content.to_i == 0
        if isbn.length == 10
          isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        else
          isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
        end
        xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
      end
      raise "not found" if doc.find_first('//openSearch:totalResults').content.to_i == 0

      title, title_transcription, date_of_publication, language, work_title, nbn = nil, nil, nil, nil, nil, nil
      authors, publishers, subjects = [], [], []

      # authors
      doc.find('//dc:creator[@xsi:type="dcndl:NDLNH"]').to_a.each do |creator|
        authors << creator.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end

      # publishers
      doc.find('//dc:publisher').to_a.each do |publisher|
        publishers << publisher.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end

      # subjects
      doc.find('//dc:subject[@xsi:type="dcndl:NDLSH"]').to_a.each do |subject|
        subjects << subject.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end

      # title
      title = doc.find('/rss/channel/item/title').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      work_title = doc.find('//dcterms:alternative').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title_transcription = doc.find('//dcndl:titleTranscription').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')

      # date of publication
      date_of_publication = Time.mktime(doc.find_first('//dcterms:issued[@xsi:type="dcterms:W3CDTF"]').content)

      # TODO: 言語が複数ある場合
      language = doc.find('//dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase

      nbn = doc.find_first('//dc:identifier[@xsi:type="dcndl:JPNO"]').content

      Patron.transaction do
        author_patrons = Manifestation.import_patrons(authors)
        publisher_patrons = Manifestation.import_patrons(publishers)

        if work_title.present?
          work = Work.new(:original_title => work_title)
        else
          work = Work.new(:original_title => title)
        end
        language_id = Language.find(:first, :conditions => {:iso_639_2 => language}).id || 1
        expression = Expression.new(
          :original_title => title,
          :expression_form_id => ExpressionForm.find(:first, :conditions => {:name => 'text'}).id,
          :frequency_of_issue_id => 1,
          :language_id => language_id
        )
        manifestation = Manifestation.new(
          :original_title => title,
          :title_transcription => title_transcription,
          :manifestation_form_id => ManifestationForm.find(:first, :conditions => {:name => 'print'}).id,
          :language_id => language_id,
          :isbn => isbn,
          :date_of_publication => date_of_publication,
          :nbn => nbn
        )
        work.restrain_indexing = true
        expression.restrain_indexing = true
        manifestation.restrain_indexing = true
        work.save!
        work.patrons << author_patrons
        work.expressions << expression
        expression.manifestations << manifestation
        manifestation.restrain_indexing = false
        manifestation.patrons << publisher_patrons

        #subjects.each do |term|
        #  subject = Subject.find(:first, :conditions => {:term => term})
        #  manifestation.subjects << subject if subject
        #  subject = Tag.find(:first, :conditions => {:name => term})
        #  manifestation.tags << subject if subject
        #end
      end

      return manifestation
    end

    def search_porta(query, options = {})
      options = {:item => 'any', :startrecord => 1, :per_page => 10, :raw => false}.merge(options)
      doc = nil
      results = {}
      if options[:startrecord] < 1
        startrecord = 1
      end
      url = "http://api.porta.ndl.go.jp/servicedp/opensearch?dpid=#{options[:dpid]}&#{options[:item]}=#{URI.escape(query)}&cnt=#{options[:per_page]}&idx=#{startrecord}"
      if options[:raw] == true
        open(url).read
      else
        RSS::Rss::Channel.install_text_element("openSearch:totalResults", "http://a9.com/-/spec/opensearchrss/1.0/", "?", "totalResults", :text, "openSearch:totalResults")
        RSS::BaseListener.install_get_text_element "http://a9.com/-/spec/opensearchrss/1.0/", "totalResults", "totalResults="
        feed = RSS::Parser.parse(url, false)
      end
    end

  end
  
  module InstanceMethods
  end
end

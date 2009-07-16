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

      doc = return_xml(isbn)
      raise "not found" if doc.find_first('//openSearch:totalResults').content.to_i == 0

      title, title_transcription, date_of_publication, language, nbn = nil, nil, nil, nil
      publishers, subjects = [], []

      # publishers
      doc.find('//dc:publisher').to_a.each do |publisher|
        publishers << publisher.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end

      # title
      title = doc.find('/rss/channel/item/title').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title_transcription = doc.find('//dcndl:titleTranscription').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')

      # date of publication
      date_of_publication = Time.mktime(doc.find_first('//dcterms:issued[@xsi:type="dcterms:W3CDTF"]').content)

      language = doc.find('//dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase
      nbn = doc.find_first('//dc:identifier[@xsi:type="dcndl:JPNO"]').content

      Patron.transaction do
        publisher_patrons = self.import_patrons(publishers)
        language_id = Language.find(:first, :conditions => {:iso_639_2 => language}).id || 1

        manifestation = Manifestation.new(
          :original_title => title,
          :title_transcription => title_transcription,
          :manifestation_form_id => ManifestationForm.find(:first, :conditions => {:name => 'print'}).id,
          :language_id => language_id,
          :isbn => isbn,
          :date_of_publication => date_of_publication,
          :nbn => nbn
        )
        manifestation.indexing = true
        manifestation.patrons << publisher_patrons
        manifestation.save(false)

        #subjects.each do |term|
        #  subject = Subject.find(:first, :conditions => {:term => term})
        #  manifestation.subjects << subject if subject
        #  subject = Tag.find(:first, :conditions => {:name => term})
        #  manifestation.tags << subject if subject
        #end
      end

      #manifestation.create_frbr_instance(doc.to_s)
      manifestation.send_later(:create_frbr_instance, doc.to_s)
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

    def return_xml(isbn)
      xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
      doc = LibXML::XML::Document.string(xml).root
      if doc.find_first('//openSearch:totalResults').content.to_i == 0
        if isbn.length == 10
          isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        else
          isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
        end
        xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
        doc = LibXML::XML::Document.string(xml).root
      end
      return doc
    end
  end
  
  module InstanceMethods
    def create_frbr_instance(xml)
      doc = self.class.return_xml(self.isbn)
      title, title_transcription, date_of_publication, language, work_title, nbn = nil, nil, nil, nil, nil, nil
      authors, publishers, subjects = [], [], []
      work_title = doc.find('//dcterms:alternative').to_a.collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      # authors
      doc.find('//dc:creator[@xsi:type="dcndl:NDLNH"]').to_a.each do |creator|
        authors << creator.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      # subjects
      doc.find('//dc:subject[@xsi:type="dcndl:NDLSH"]').to_a.each do |subject|
        subjects << subject.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      # TODO: 言語が複数ある場合
      language = doc.find('//dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase

      Patron.transaction do
        author_patrons = Manifestation.import_patrons(authors)
        if work_title.present?
          work = Work.new(:original_title => work_title)
        else
          work = Work.new(:original_title => self.original_title)
        end
        language_id = Language.find(:first, :conditions => {:iso_639_2 => language}).id || 1
        expression = Expression.new(
          :original_title => work.title,
          :expression_form_id => ExpressionForm.find(:first, :conditions => {:name => 'text'}).id,
          :frequency_of_issue_id => 1,
          :language_id => language_id
        )
        work.save!
        work.patrons << author_patrons
        work.expressions << expression
        expression.manifestations << self
      end
      self.save
    end
  end
end

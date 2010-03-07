# -*- encoding: utf-8 -*-
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

      if manifestation = self.first(:conditions => {:isbn => isbn})
        raise 'already imported'
      end

      doc = return_xml(isbn)
      raise "not found" if doc.at('//openSearch:totalResults').content.to_i == 0

      date_of_publication, language, nbn = nil, nil, nil

      publishers = get_publishers(doc)

      # title
      title = get_title(doc)

      # date of publication
      date_of_publication = Time.mktime(doc.at('//dcterms:issued[@xsi:type="dcterms:W3CDTF"]').content)

      language = get_language(doc)
      nbn = doc.at('//dc:identifier[@xsi:type="dcndl:JPNO"]').content

      Patron.transaction do
        publisher_patrons = self.import_patrons(publishers)
        language_id = Language.first(:conditions => {:iso_639_2 => language}).id || 1

        manifestation = Manifestation.new(
          :original_title => title[:manifestation],
          :title_transcription => title[:transcription],
          # TODO: PORTAに入っている図書以外の資料を調べる
          :carrier_type_id => CarrierType.first(:conditions => {:name => 'print'}).id,
          :language_id => language_id,
          :isbn => isbn,
          :date_of_publication => date_of_publication,
          :nbn => nbn
        )
        manifestation.patrons << publisher_patrons
        manifestation.save!
      end

      #manifestation.send_later(:create_frbr_instance, doc.to_s)
      manifestation.create_frbr_instance(doc)
      return manifestation
    end

    def search_porta(query, options = {})
      options = {:item => 'any', :startrecord => 1, :per_page => 10, :raw => false}.merge(options)
      doc = nil
      results = {}
      startrecord = options[:startrecord].to_i
      if startrecord == 0
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
      doc = Nokogiri::XML(xml)
      if doc.at('//openSearch:totalResults').content.to_i == 0
        isbn = normalize_isbn(isbn)
        xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
        doc = Nokogiri::XML(xml)
      end
      return doc
    end

    def normalize_isbn(isbn)
      if isbn.length == 10
        ISBN_Tools.isbn10_to_isbn13(isbn)
      else
        ISBN_Tools.isbn13_to_isbn10(isbn)
      end
    end

    def get_title(doc)
      title = {}
      title[:manifestation] = doc.xpath('//item/title').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title[:transcription] = doc.xpath('//item/dcndl:titleTranscription').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title[:original] = doc.xpath('//dcterms:alternative').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      return title
    end

    def get_authors(doc)
      authors = []
      doc.xpath('//dc:creator[@xsi:type="dcndl:NDLNH"]').each do |creator|
        authors << creator.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return authors
    end

    def get_subjects(doc)
      subjects = []
      doc.xpath('//dc:subject[@xsi:type="dcndl:NDLSH"]').each do |subject|
        subjects << subject.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return subjects
    end

    def get_language(doc)
      # TODO: 言語が複数ある場合
      language = doc.xpath('//dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase
    end

    def get_publishers(doc)
      publishers = []
      doc.xpath('//dc:publisher').each do |publisher|
        publishers << publisher.content.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return publishers
    end
  end
  
  module InstanceMethods
    def create_frbr_instance(doc)
      title = self.class.get_title(doc)
      authors = self.class.get_authors(doc)
      language = self.class.get_language(doc)
      subjects = self.class.get_subjects(doc)

      Patron.transaction do
        author_patrons = self.class.import_patrons(authors)
        if title[:original].present?
          work = Work.new(:original_title => title[:original])
        else
          work = Work.new(:original_title => title[:manifestation], :title_transcription => title[:transcription])
        end
        language_id = Language.first(:conditions => {:iso_639_2 => language}).id rescue 1
        content_type_id = ContentType.first(:conditions => {:name => 'text'}).id rescue 1
        expression = Expression.new(
          :original_title => work.original_title,
          :content_type_id => content_type_id,
          :language_id => language_id
        )
        work.save!
        work.patrons << author_patrons
        subjects.each do |term|
          subject = Subject.first(:conditions => {:term => term})
          work.subjects << subject if subject
          #subject = Tag.first(:conditions => {:name => term})
          #manifestation.tags << subject if subject
        end
        work.expressions << expression
        expression.manifestations << self
      end
    end
  end
end

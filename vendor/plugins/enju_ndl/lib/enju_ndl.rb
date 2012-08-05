# -*- encoding: utf-8 -*-
module EnjuNdl
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_ndl
      include EnjuNdl::InstanceMethods
    end

    def import_isbn(isbn)
      lisbn = Lisbn.new(isbn)
      raise EnjuNdl::InvalidIsbn unless lisbn.valid?

      if manifestation = Manifestation.first(:conditions => {:isbn => isbn})
        return manifestation
      end

      doc = return_xml(isbn)
      raise EnjuNdl::RecordNotFound if doc.at('//openSearch:totalResults').content.to_i == 0

      date_of_publication, language, nbn, ndc = nil, nil, nil, nil

      publishers = get_publishers(doc)

      # title
      title = get_title(doc)

      # date of publication
      date_of_publication = Time.mktime(doc.at('//dcterms:issued[@xsi:type="dcterms:W3CDTF"]').content)

      language = get_language(doc)
      nbn = doc.at('//dc:identifier[@xsi:type="dcndl:JPNO"]').content
      ndc = doc.at('//dc:subject[@xsi:type="dcndl:NDC"]').try(:content)

      Patron.transaction do
        publisher_patrons = Patron.import_patrons(publishers)
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
        #manifestation.save!
      end

      #manifestation.send_later(:create_frbr_instance, doc.to_s)
      manifestation.create_frbr_instance(doc)
      return manifestation
    end

    def import_isbn!(isbn)
      manifestation = import_isbn(isbn)
      manifestation.save!
      manifestation
    end

    def search_ndl(query, options = {})
      options = {:dpid => 'iss-ndl-opac', :item => 'any', :idx => 1, :per_page => 10, :raw => false}.merge(options)
      doc = nil
      results = {}
      startrecord = options[:idx].to_i
      if startrecord == 0
        startrecord = 1
      end
      url = "http://iss.ndl.go.jp/api/opensearch?dpid=#{options[:dpid]}&#{options[:item]}=#{URI.escape(query)}&cnt=#{options[:per_page]}&idx=#{startrecord}"
      if options[:raw] == true
        open(url).read
      else
        RSS::Rss::Channel.install_text_element("openSearch:totalResults", "http://a9.com/-/spec/opensearchrss/1.0/", "?", "totalResults", :text, "openSearch:totalResults")
        RSS::BaseListener.install_get_text_element "http://a9.com/-/spec/opensearchrss/1.0/", "totalResults", "totalResults="
        feed = RSS::Parser.parse(url, false)
      end
    end

    def normalize_isbn(isbn)
      if isbn.length == 10
        Lisbn.new(isbn).isbn13
      else
        Lisbn.new(isbn).isbn10
      end
    end

    def return_xml(isbn)
      xml = self.search_ndl(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
      doc = Nokogiri::XML(xml)
      if doc.at('//openSearch:totalResults').content.to_i == 0
        isbn = normalize_isbn(isbn)
        xml = self.search_ndl(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
        doc = Nokogiri::XML(xml)
      end
      return doc
    end

    def get_title(doc)
      title = {
        :manifestation => doc.xpath('//item[1]/title').collect(&:content).join(' '), #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
        :transcription => doc.xpath('//item[1]/dcndl:titleTranscription').collect(&:content).join(' '), #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
        :original => doc.xpath('//dcterms:alternative').collect(&:content).join(' ') #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      }
    end

    def get_authors(doc)
      authors = []
      doc.xpath('//item[1]/dc:creator[@xsi:type="dcndl:NDLNH"]').each do |creator|
        authors << creator.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return authors
    end

    def get_subjects(doc)
      subjects = []
      doc.xpath('//item[1]/dc:subject[@xsi:type="dcndl:NDLSH"]').each do |subject|
        subjects << subject.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return subjects
    end

    def get_language(doc)
      # TODO: 言語が複数ある場合
      language = doc.xpath('//item[1]/dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase
    end

    def get_publishers(doc)
      publishers = []
      doc.xpath('//item[1]/dc:publisher').each do |publisher|
        publishers << publisher.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return publishers
    end

    def rss_import(url)
      doc = Nokogiri::XML(open(url))
      ns = {"dc" => "http://purl.org/dc/elements/1.1/", "xsi" => "http://www.w3.org/2001/XMLSchema-instance", "dcndl" => "http://ndl.go.jp/dcndl/terms/"}
      doc.xpath('//item', ns).each do |item|
        isbn = item.at('./dc:identifier[@xsi:type="dcndl:ISBN"]').try(:content)
        ndl_bib_id = item.at('./dc:identifier[@xsi:type="dcndl:NDLBibID"]').try(:content)
        manifestation = Manifestation.find_by_ndl_bib_id(ndl_bib_id)
        manifestation = Manifestation.find_by_isbn(isbn) unless manifestation
        unless manifestation
          manifestation = self.create(
            :original_title => item.at('./dc:title').content,
            :title_transcription => item.at('./dcndl:titleTranscription').try(:content),
            :isbn => isbn,
            :ndl_bib_id => ndl_bib_id,
            :description => item.at('./dc:description').try(:content),
            :date_of_publication => item.at('./pubDate').try(:content)
          )
          item.xpath('./dc:creator').each_with_index do |creator, i|
            next if i == 0
            patron = Patron.first(:conditions => {:full_name => creator.try(:content)})
            patron =  Patron.new(:full_name => creator.try(:content)) unless patron
            manifestation.creators << patron if patron.valid?
          end
          item.xpath('./dc:publisher').each_with_index do |publisher, i|
            patron = Patron.first(:conditions => {:full_name => publisher.try(:content)})
            patron =  Patron.new(:full_name => publisher.try(:content)) unless patron
            manifestation.publishers << patron if patron.valid?
          end
        end
      end
      Sunspot.commit
    end
  end

  module InstanceMethods
    def create_frbr_instance(doc)
      title = self.class.get_title(doc)
      authors = self.class.get_authors(doc)
      language = self.class.get_language(doc)
      subjects = self.class.get_subjects(doc)

      Patron.transaction do
        author_patrons = Patron.import_patrons(authors)
        work = self.similar_works.first
        unless work
          if title[:original].present?
            work = Work.new(:original_title => title[:original])
          else
            work = Work.new(:original_title => title[:manifestation], :title_transcription => title[:transcription])
          end
        end
        language_id = Language.first(:conditions => {:iso_639_2 => language}).id rescue 1
        content_type_id = ContentType.first(:conditions => {:name => 'text'}).id rescue 1
        expression = Expression.new(
          :original_title => work.original_title,
          :content_type_id => content_type_id,
          :language_id => language_id
        )
        work.save
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

  class RecordNotFound < StandardError
  end

  class InvalidIsbn < StandardError
  end
end

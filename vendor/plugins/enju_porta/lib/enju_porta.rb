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
      if isbn.length == 10
        isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
      end

      if manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn})
        raise 'already imported'
      end

      result = search_z3950(isbn)
      raise "not found" if result.nil?

      title, title_transcription, date_of_publication, language, work_title, nbn = nil, nil, nil, nil, nil, nil
      authors, publishers, subjects = [], [], []

      result.to_s.split("\n").each do |line|
        if md = /^【(.*?)】：原タイトル：(.*?)$/.match(line)
          work_title = md[1].tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
        elsif md = /^【(.*?)】：(.*?)$/.match(line)
          case md[1]
          when 'title'
            title = md[2].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
          when 'titleTranscription'
            title_transcription = md[2].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
          when 'publisher'
            publishers << md[2].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
          end
        elsif md = /^【(.*?)】\((.*?)\)：(.*?)$/.match(line)
          case md[1]
          when 'creator'
            authors << md[3].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')  if md[2] === 'dcndl:NDLNH'
          when 'subject'
            subjects << md[3].tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ') if md[2] == 'dcndl:NDLSH'
          when 'issued'
            date_of_publication = Time.mktime(md[3]) if md[2] == 'dcterms:W3CDTF'
          when 'language'
            language = md[3].downcase if md[2] == 'dcterms:ISO639-2'
          when 'identifier'
            nbn = "JP-#{md[3]}" if md[2] == 'dcndl:JPNO'
          end
        end
      end

      Patron.transaction do
        author_patrons = Manifestation.import_patrons(authors.reverse)
        publisher_patrons = Manifestation.import_patrons(publishers)

        if work_title
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
        #manifestation.restrain_indexing = true
        work.save!
        work.patrons << author_patrons
        work.expressions << expression
        expression.manifestations << manifestation
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

    def z3950query (isbn, host, port, db)
      begin
        ZOOM::Connection.open(host, port) do |conn|
          conn.database_name = db
          conn.preferred_record_syntax = 'SUTRS'
          rset = conn.search("@attr 1=7 #{isbn}")
          return rset[0]
        end
      rescue Exception => e
        nil
      end
    end

    def search_z3950(isbn)
      server = ["api.porta.ndl.go.jp", 210, "zomoku"]
      result = z3950query(isbn, server[0], server[1], server[2])
      if result.nil?
        if isbn.length == 10
          isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        elsif isbn.length == 13
          isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
        end
        result = z3950query(isbn, server[0], server[1], server[2])
      end
      return result
    end

    def search_porta(query, dpid, startrecord = 1, per_page = 10)
      doc = nil
      results = {}
      if startrecord < 1
        startrecord = 1
      end
      url = "http://api.porta.ndl.go.jp/servicedp/opensearch?dpid=#{dpid}&any=#{URI.escape(query)}&cnt=#{per_page}&idx=#{startrecord}"
      #rss = open(url).read
      rss = APICache.get(url)
      RSS::Rss::Channel.install_text_element("openSearch:totalResults", "http://a9.com/-/spec/opensearchrss/1.0/", "?", "totalResults", :text, "openSearch:totalResults")
      RSS::BaseListener.install_get_text_element "http://a9.com/-/spec/opensearchrss/1.0/", "totalResults", "totalResults="
      feed = RSS::Parser.parse(url, false)
    end

  end
  
  module InstanceMethods
  end
end

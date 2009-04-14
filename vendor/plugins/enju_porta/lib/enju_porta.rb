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

      title, title_transcription, date_of_publication, language = nil, nil, nil, nil
      authors, publishers, subjects = [], [], []

      result.to_s.split("\n").each do |line|
        if md = /^【title】：+(.*)$/.match(line) 
          title = md[1].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
        elsif md = /^【titleTranscription】：+(.*)$/.match(line) 
          title_transcription = md[1].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
        elsif md = /^【creator】\(dcndl:NDLNH\)：+(.*)$/.match(line)
          authors << md[1].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ') 
        elsif md = /^【publisher】：+(.*)$/.match(line)
          publishers << md[1].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
        elsif md = /^【subject】\(dcndl:NDLNH\)：+(.*)$/.match(line)
          subjects << md[1].tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
        elsif md = /^【issued】\(dcterms:W3CDTF\)：+(.*)$/.match(line)
          date_of_publication = Time.mktime(md[1])
        elsif md = /^【language】\(dcterms:ISO639-2\)：+(.*)$/.match(line)
          language = md[1]
        end
      end

      Patron.transaction do
        author_patrons = Manifestation.import_patrons(authors.reverse)
        publisher_patrons = Manifestation.import_patrons(publishers)

        work = Work.new(:original_title => title)
        # TODO: 言語や形態の設定
        expression = Expression.new(:original_title => title, :expression_form_id => 1, :frequency_of_issue_id => 1, :language_id => 1)
        manifestation = Manifestation.new(:original_title => title, :manifestation_form_id => 1, :language_id => 1, :isbn => isbn, :date_of_publication => date_of_publication)
        work.restrain_indexing = true
        expression.restrain_indexing = true
        #manifestation.restrain_indexing = true
        work.save!
        work.patrons << author_patrons
        work.expressions << expression
        expression.manifestations << manifestation
        manifestation.patrons << publisher_patrons

        subjects.each do |term|
          subject = Subject.find(:first, :conditions => {:term => term})
          manifestation.subjects << subject if subject
        end
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

  end
  
  module InstanceMethods
  end
end

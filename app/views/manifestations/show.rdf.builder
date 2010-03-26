xml.instruct! :xml, :version=>"1.0" 
xml.rdf(:RDF,
        'xmlns'  => "http://purl.org/rss/1.0/",
        'xmlns:rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:foaf' => "http://xmlns.com/foaf/0.1/",
        'xmlns:prism' => "http://prismstandard.org/namespaces/basic/2.0/",
        'xmlns:rdfs' =>"http://www.w3.org/2000/01/rdf-schema#") do
  xml.rdf(:Description, 'rdf:about' => manifestation_url(@manifestation)) do
    xml.title h(@manifestation.original_title)
    #xml.description(@manifestation.original_title)
    xml.tag! 'dc:date', h(@manifestation.created_at.utc.iso8601)
    xml.tag! 'dc:creator', @manifestation.author.join(' ') unless @manifestation.authors.empty?
    @manifestation.authors.each do |author|
      xml.tag! 'foaf:maker' do
        xml.tag! 'foaf:Person' do
          xml.tag! 'foaf:name', author.full_name
          xml.tag! 'foaf:name', author.full_name_transcription if author.full_name_transcription.present?
        end
      end
    end
    xml.tag! 'dc:contributor', @manifestation.editor.join(' ') unless @manifestation.editors.empty?
    xml.tag! 'dc:publisher', @manifestation.publisher.join(' ') unless @manifestation.publishers.empty?
    xml.tag! 'dc:identifier', "urn:ISBN:#{@manifestation.isbn}" if @manifestation.isbn.present?
    xml.tag! 'dc:description', @manifestation.description
    xml.link manifestation_url(@manifestation)
    @manifestation.subjects.each do |subject|
      xml.tag! "foaf:topic", "rdf:resource" => subject_url(subject)
    end
  end
end

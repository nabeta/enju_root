xml.tag!("oai_dc:dc",
  'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
  'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
  'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
  'xsi:schemaLocation' =>
    %{http://www.openarchives.org/OAI/2.0/oai_dc/
    http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
      xml.tag!('oai_dc:title', original_title)
      xml.tag!('oai_dc:description', note)
      @manifestation.authors.each do |author|
        xml.tag!('oai_dc:creator', author.full_name)
      end
      @manifestation.languages.each do |language|
        xml.tag!('oai_dc:lang', language.name)
      end
      @manifestation.subjects.each do |subject|
        xml.tag!('oai_dc:subject', subject.term)
      end
end

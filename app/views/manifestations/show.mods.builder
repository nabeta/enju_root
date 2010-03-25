xml.instruct! :xml, :version=>"1.0" 
xml.mods('version' => "3.3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  xml.titleInfo{
    xml.title @manifestation.original_title
  }
  @manifestation.authors.each do |author|
    case author.patron_type.name
    when "Person"
      xml.name('type' => 'personal'){
        xml.namePart author.full_name
        xml.namePart author.date if author.date
        xml.role do
          xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
        end
      }
    when "CorporateBody"
      xml.name('type' => 'corporate'){
        xml.namePart author.full_name
      }
    when "Conference"
      xml.name('type' => 'conference'){
        xml.namePart author.full_name
      }
    end
  end
  xml.typeOfResource @manifestation.carrier_type.mods_type
  xml.originInfo{
    @manifestation.patrons.each do |patron|
      xml.publisher patron.full_name
    end
    xml.dateIssued @manifestation.date_of_publication
  }
  xml.language{
    xml.languageTerm @manifestation.expressions.first.language.iso_639_2, 'authority' => 'iso639-2b', 'type' => 'code' if @manifestation.expressions.first
  }
  xml.physicalDescription{
    xml.form @manifestation.carrier_type.name, 'authority' => 'marcform'
    extent = []
    extent << @manifestation.number_of_pages if @manifestation.number_of_pages
    extent << @manifestation.height if @manifestation.height
    xml.extent extent.join("; ")
  }
  xml.subject{
    @manifestation.subjects.each do |subject|
      xml.topic subject.term
    end
  }
  xml.identifier @manifestation.isbn, :type => 'isbn'
  xml.identifier @manifestation.lccn, :type => 'lccn'
  xml.recordInfo{
    xml.recordCreationDate @manifestation.created_at
    xml.recordChangeDate @manifestation.updated_at
    xml.recordIdentifier @manifestation.url
  }
}

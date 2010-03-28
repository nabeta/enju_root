xml.instruct! :xml, :version=>"1.0" 
xml.mods('version' => "3.3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  xml.titleInfo{
    xml.title @manifestation.original_title
  }
  xml.titleInfo('type' => 'alternative'){
    xml.title @manifestation.title_alternative
  }
  @manifestation.creators.each do |creator|
    case creator.patron_type.name
    when "Person"
      xml.name('type' => 'personal'){
        xml.namePart creator.full_name
        xml.namePart creator.date if creator.date
        xml.role do
          xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
        end
      }
    when "CorporateBody"
      xml.name('type' => 'corporate'){
        xml.namePart creator.full_name
        xml.role do
          xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
        end
      }
    when "Conference"
      xml.name('type' => 'conference'){
        xml.namePart creator.full_name
        xml.role do
          xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
        end
      }
    end
  end
  @manifestation.contributors.each do |contributor|
    case contributor.patron_type.name
    when "Person"
      xml.name('type' => 'personal'){
        xml.namePart contributor.full_name
        xml.namePart contributor.date if contributor.date
      }
    when "CorporateBody"
      xml.name('type' => 'corporate'){
        xml.namePart contributor.full_name
      }
    when "Conference"
      xml.name('type' => 'conference'){
        xml.namePart contributor.full_name
      }
    end
  end
  xml.typeOfResource @manifestation.carrier_type.mods_type
  xml.originInfo{
    @manifestation.patrons.each do |patron|
      xml.publisher patron.full_name
    end
    xml.dateIssued @manifestation.date_of_publication
    xml.frequency @manifestation.frequency.name
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
  @manifestation.subjects.collect(&:classifications).flatten.each do |classification|
    xml.classification classification.category, 'authority' => classification.classification_type.name
  end
  xml.abstract @manifestation.description
  xml.note @manifestation.note
  xml.identifier @manifestation.isbn, :type => 'isbn'
  xml.identifier @manifestation.lccn, :type => 'lccn'
  xml.recordInfo{
    xml.recordCreationDate @manifestation.created_at
    xml.recordChangeDate @manifestation.updated_at
    xml.recordIdentifier @manifestation.url
  }
}

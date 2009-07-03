xml.instruct! :xml, :version=>"1.0" 
xml.rsp('xmlns' => "http://worldcat.org/xid/isbn/",
        'stat' => "ok"){
  @manifestation.related_manifestations.each do |manifestation|
    xml.isbn manifestation.isbn, 'year' => manifestation.date_of_publication.try(:year), 'lang' => manifestation.language.iso_639_2
  end
}

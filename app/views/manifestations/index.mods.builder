xml.instruct! :xml, :version=>"1.0" 
xml.modsCollection(
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  @manifestations.each do |manifestation|
    cache(:id => manifestation.id, :action => 'show', :controller => 'manifestations', :role => current_user.try(:highest_role).try(:name), :format_suffix => 'mods', :locale => @locale) do
      xml << render(:partial => 'show', :locals => {:manifestation => manifestation})
    end
  end
}

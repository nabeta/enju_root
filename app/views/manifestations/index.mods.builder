xml.instruct! :xml, :version=>"1.0" 
xml.modsCollection(
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  @manifestations.each do |manifestation|
    cache(:controller => :manifestations, :action => :show, :id => manifestation.id, :page => 'mods', :role => current_user_role_name, :locale => @locale) do
      xml << render(:partial => 'show', :locals => {:manifestation => manifestation})
    end
  end
}

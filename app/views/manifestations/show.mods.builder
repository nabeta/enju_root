xml.instruct! :xml, :version=>"1.0" 
xml.mods('version' => "3.3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  cache(:id => @manifestation.id, :action => 'show', :controller => 'manifestations', :role => current_user_role_name, :format_suffix => 'mods', :locale => @locale) do
    xml << render(:partial => 'show', :locals => {:manifestation => @manifestation})
  end
}

atom_feed(:url => manifestations_url(:format => :atom)) do |feed|
  feed.title t('manifestation.query_search_result', :query => @query, :library_group_name => @library_group.display_name.localize)
  feed.updated(@manifestations.first ? @manifestations.first.created_at : Time.zone.now)

  @manifestations.each do |manifestation|
    cache(:id => manifestation.id, :action => 'show', :controller => 'manifestations', :role => current_user.try(:highest_role).try(:name), :format_suffix => 'atom', :locale => @locale) do
      feed.entry(manifestation) do |entry|
        entry.title(manifestation.original_title)
        entry.content(manifestation.tags.join(' '), :type => 'html')

        manifestation.creators.each do |patron|
          entry.author do |author|
            author.name(patron.full_name)
          end
        end
      end
    end
  end
end

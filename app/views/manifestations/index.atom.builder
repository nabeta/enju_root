atom_feed(:url => manifestations_url(:format => :atom)) do |feed|
  feed.title t('manifestation.query_search_result', :query => @query, :library_group_name => @library_group.display_name.localize)
  feed.updated(@manifestations.first ? @manifestations.first.created_at : Time.zone.now)

  @manifestations.each do |manifestation|
    cache(:controller => :manifestations, :action => :show, :id => manifestation.id, :page => 'atom', :role => current_user_role_name, :locale => @locale) do
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

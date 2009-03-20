module EnjuGoogleBookSearchHelper
  def google_book_search_preview(isbn)
    render :partial => 'google_book_search', :locals => {:isbn => isbn}
  end
end

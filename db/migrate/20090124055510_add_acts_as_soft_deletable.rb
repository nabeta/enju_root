class AddActsAsSoftDeletable < ActiveRecord::Migration
  def self.up
    Patron::Deleted.create_table
    User::Deleted.create_table
    Work::Deleted.create_table
    Expression::Deleted.create_table
    Manifestation::Deleted.create_table
    Item::Deleted.create_table
    Library::Deleted.create_table
    Shelf::Deleted.create_table
    Reserve::Deleted.create_table
    PurchaseRequest::Deleted.create_table
    Question::Deleted.create_table
    Answer::Deleted.create_table
    Bookstore::Deleted.create_table
    Advertisement::Deleted.create_table
    InterLibraryLoan::Deleted.create_table
    MessageQueue::Deleted.create_table
    OrderList::Deleted.create_table
    Subscription::Deleted.create_table
    Event::Deleted.create_table
  end

  def self.down
    Patron::Deleted.drop_table
    User::Deleted.drop_table
    Work::Deleted.drop_table
    Expression::Deleted.drop_table
    Manifestation::Deleted.drop_table
    Item::Deleted.drop_table
    Library::Deleted.drop_table
    Shelf::Deleted.drop_table
    Reserve::Deleted.drop_table
    PurchaseRequest::Deleted.drop_table
    Question::Deleted.drop_table
    Answer::Deleted.drop_table
    Bookstore::Deleted.drop_table
    Advertisement::Deleted.drop_table
    InterLibraryLoan::Deleted.drop_table
    MessageQueue::Deleted.drop_table
    OrderList::Deleted.drop_table
    Subscription::Deleted.drop_table
    Event::Deleted.drop_table
  end
end

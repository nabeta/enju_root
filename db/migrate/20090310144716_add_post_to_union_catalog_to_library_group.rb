class AddPostToUnionCatalogToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :post_to_union_catalog, :boolean, :default => false
  end

  def self.down
    remove_column :library_groups, :post_to_union_catalog
  end
end

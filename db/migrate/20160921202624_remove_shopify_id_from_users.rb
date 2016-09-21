class RemoveShopifyIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :shopify_id, :integer
  end
end

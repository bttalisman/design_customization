class AddShopifyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shopify_id, :string
  end
end

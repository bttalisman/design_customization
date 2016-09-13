class AddDescriptionToManagedAsset < ActiveRecord::Migration
  def change
    add_column :managed_assets, :description, :text
  end
end

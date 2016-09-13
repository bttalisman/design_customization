class AddNameToManagedAssets < ActiveRecord::Migration
  def change
    add_column :managed_assets, :name, :string
  end
end

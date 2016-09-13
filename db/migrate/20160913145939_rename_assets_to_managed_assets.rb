class RenameAssetsToManagedAssets < ActiveRecord::Migration
  def change
    rename_table :assets, :managed_assets
  end
end

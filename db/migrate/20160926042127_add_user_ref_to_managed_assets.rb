class AddUserRefToManagedAssets < ActiveRecord::Migration
  def change
    add_reference :managed_assets, :user, index: true, foreign_key: true
  end
end

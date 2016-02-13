class AddNameToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :name, :string
  end
end

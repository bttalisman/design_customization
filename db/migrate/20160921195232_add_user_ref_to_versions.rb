class AddUserRefToVersions < ActiveRecord::Migration
  def change
    add_reference :versions, :user, index: true, foreign_key: true
  end
end

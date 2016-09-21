class AddVersionRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :version, index: true, foreign_key: true
  end
end

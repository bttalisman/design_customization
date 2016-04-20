class AddVersionRefToCollage < ActiveRecord::Migration
  def change
    add_column :collages, :version_id, :integer
  end
end

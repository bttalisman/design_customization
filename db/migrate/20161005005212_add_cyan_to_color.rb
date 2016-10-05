class AddCyanToColor < ActiveRecord::Migration
  def change
    add_column :colors, :cyan, :float
  end
end

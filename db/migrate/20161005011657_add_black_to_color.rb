class AddBlackToColor < ActiveRecord::Migration
  def change
    add_column :colors, :black, :float
  end
end

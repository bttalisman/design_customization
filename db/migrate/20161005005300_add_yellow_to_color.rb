class AddYellowToColor < ActiveRecord::Migration
  def change
    add_column :colors, :yellow, :float
  end
end

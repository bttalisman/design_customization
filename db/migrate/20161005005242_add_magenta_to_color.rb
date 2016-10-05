class AddMagentaToColor < ActiveRecord::Migration
  def change
    add_column :colors, :magenta, :float
  end
end

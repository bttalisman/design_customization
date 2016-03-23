class AddPaletteRefToColors < ActiveRecord::Migration
  def change
    add_reference :colors, :palette, index: true, foreign_key: true
  end
end

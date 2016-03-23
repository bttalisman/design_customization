class CreateJoinTableColorPalette < ActiveRecord::Migration
  def change
    create_join_table :colors, :palettes do |t|
      # t.index [:color_id, :palette_id]
      # t.index [:palette_id, :color_id]
    end
  end
end

class AddExtractedToColor < ActiveRecord::Migration
  def change
    add_column :colors, :extracted, :boolean
  end
end

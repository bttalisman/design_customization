class RemoveExtractedFromColor < ActiveRecord::Migration
  def change
    remove_column :colors, :extracted, :boolean
  end
end

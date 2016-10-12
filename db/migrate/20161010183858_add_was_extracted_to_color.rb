class AddWasExtractedToColor < ActiveRecord::Migration
  def change
    add_column :colors, :was_extracted, :boolean, :default => false
  end
end

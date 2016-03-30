class AddDescriptionToPalettes < ActiveRecord::Migration
  def change
    add_column :palettes, :description, :string
  end
end

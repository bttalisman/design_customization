class AddImageNameToReplacementImages < ActiveRecord::Migration
  def change
    add_column :replacement_images, :image_name, :string
  end
end

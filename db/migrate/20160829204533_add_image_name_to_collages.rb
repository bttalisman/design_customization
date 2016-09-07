class AddImageNameToCollages < ActiveRecord::Migration
  def change
    add_column :collages, :image_name, :string
  end
end

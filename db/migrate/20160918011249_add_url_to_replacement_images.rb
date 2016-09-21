class AddUrlToReplacementImages < ActiveRecord::Migration
  def change
    add_column :replacement_images, :url, :string
  end
end

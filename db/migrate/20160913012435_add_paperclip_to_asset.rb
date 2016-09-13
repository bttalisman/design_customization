class AddPaperclipToAsset < ActiveRecord::Migration
  def change
    add_attachment :assets, :image
  end
end

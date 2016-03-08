class AddPaperclipToReplacementImage < ActiveRecord::Migration
  def change
    add_attachment :replacement_images, :uploaded_file    
  end
end

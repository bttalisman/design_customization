class AddPaperclipToDesignTemplate < ActiveRecord::Migration
  def change
    add_attachment :design_templates, :original_file    
  end
end

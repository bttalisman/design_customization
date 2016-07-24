class RemoveOrigFilePathFromDesignTemplates < ActiveRecord::Migration
  def change
    remove_column :design_templates, :orig_file_path, :string
  end
end

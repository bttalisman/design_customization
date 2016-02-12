class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :output_folder_path
      t.column :values, :json   # Edited
      t.integer :design_template_id
      t.timestamps null: false
    end
  end
end

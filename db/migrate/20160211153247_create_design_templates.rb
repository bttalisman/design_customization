class CreateDesignTemplates < ActiveRecord::Migration
  def change
    create_table :design_templates do |t|
      t.string :orig_file_path
      t.string :name
      t.text :prompts
      t.timestamps null: false
    end
  end
end

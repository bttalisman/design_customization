class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :orig_file_path
      t.string :name
      t.json :prompts

      t.timestamps null: false
    end
  end
end

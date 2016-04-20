class CreateReplacementImages < ActiveRecord::Migration
  def change
    create_table :replacement_images do |t|
      t.integer :version_id
      t.timestamps null: false
    end
  end
end

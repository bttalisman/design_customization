class CreateCollages < ActiveRecord::Migration
  def change
    create_table :collages do |t|
      t.string :path
      t.string :query

      t.timestamps null: false
    end
  end
end

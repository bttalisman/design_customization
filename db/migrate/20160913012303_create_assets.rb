class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|

      t.timestamps null: false
    end
  end
end

class AddDescriptionToColors < ActiveRecord::Migration
  def change
    add_column :colors, :description, :string
  end
end

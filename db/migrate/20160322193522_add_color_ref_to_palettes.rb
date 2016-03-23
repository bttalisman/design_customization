class AddColorRefToPalettes < ActiveRecord::Migration
  def change
    add_reference :palettes, :color, index: true, foreign_key: true
  end
end

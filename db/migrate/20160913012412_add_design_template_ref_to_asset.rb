class AddDesignTemplateRefToAsset < ActiveRecord::Migration
  def change
    add_reference :assets, :design_template, index: true, foreign_key: true
  end
end

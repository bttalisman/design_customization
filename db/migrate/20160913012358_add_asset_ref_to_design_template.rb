class AddAssetRefToDesignTemplate < ActiveRecord::Migration
  def change
    add_reference :design_templates, :asset, index: true, foreign_key: true
  end
end

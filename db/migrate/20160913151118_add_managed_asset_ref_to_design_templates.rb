class AddManagedAssetRefToDesignTemplates < ActiveRecord::Migration
  def change
    add_reference :design_templates, :managed_asset, index: true, foreign_key: true
  end
end

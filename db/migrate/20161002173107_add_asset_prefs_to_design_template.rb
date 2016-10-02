class AddAssetPrefsToDesignTemplate < ActiveRecord::Migration
  def change
    add_column :design_templates, :asset_prefs, :text
  end
end

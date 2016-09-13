class RemoveAssetRefFromDesignTemplates < ActiveRecord::Migration
  def change
    remove_reference :design_templates, :asset, index: true, foreign_key: true
  end
end

class CreateJoinTableManagedAssetDesignTemplate < ActiveRecord::Migration
  def change
    create_join_table :managed_assets, :design_templates do |t|
      # t.index [:managed_asset_id, :design_template_id]
      # t.index [:design_template_id, :managed_asset_id]
    end
  end
end

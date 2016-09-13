class AddHasBeenPostProcessedToDesignTemplates < ActiveRecord::Migration
  def change
    add_column :design_templates, :has_been_post_processed, :boolean, :default => false
  end
end

class AddIsTransButtToDesignTemplates < ActiveRecord::Migration
  def change
    add_column :design_templates, :is_trans_butt, :boolean, :default => false
  end
end

class AddUserRefToDesignTemplates < ActiveRecord::Migration
  def change
    add_reference :design_templates, :user, index: true, foreign_key: true
  end
end

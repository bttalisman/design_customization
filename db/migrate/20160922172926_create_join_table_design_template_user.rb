class CreateJoinTableDesignTemplateUser < ActiveRecord::Migration
  def change
    create_join_table :design_templates, :users do |t|
      # t.index [:design_template_id, :user_id]
      # t.index [:user_id, :design_template_id]
    end
  end
end

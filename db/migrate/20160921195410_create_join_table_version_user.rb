class CreateJoinTableVersionUser < ActiveRecord::Migration
  def change
    create_join_table :versions, :users do |t|
      # t.index [:version_id, :user_id]
      # t.index [:user_id, :version_id]
    end
  end
end

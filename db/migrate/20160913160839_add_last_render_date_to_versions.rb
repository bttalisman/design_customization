class AddLastRenderDateToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :last_render_date, :datetime
  end
end

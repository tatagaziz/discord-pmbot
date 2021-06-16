class RemoveUnusedColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :project_leader_id, :integer
  end
end

class AddServerRefToProjects < ActiveRecord::Migration[6.1]
  def change
    add_reference :projects, :server, null: false, foreign_key: true
    change_table :projects do |t|
      t.rename :project_leaders_id, :project_leader_id
    end
  end
end

class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :description
      t.integer :project_leader_id

      t.timestamps
    end

    add_reference :projects, :project_leaders
  end
end

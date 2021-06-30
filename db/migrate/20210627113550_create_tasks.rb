class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :status
      t.string :description
      t.string :assignee_discord_id

      t.timestamps
    end

    add_reference :tasks, :project_leader, foreign_key: true
  end
end

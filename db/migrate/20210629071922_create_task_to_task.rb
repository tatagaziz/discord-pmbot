class CreateTaskToTask < ActiveRecord::Migration[6.1]
  def change
    create_table :task_to_tasks do |t|
      t.bigint :parent_task_id, foreign_key: true
      t.bigint :child_task_id, foreign_key: true
    end
  end
end

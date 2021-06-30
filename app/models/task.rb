class Task < ApplicationRecord
  FINISHED = "1"
  UNFINISHED = "0"

  has_many :parent_task_tables, foreign_key: :parent_task_id, class_name: "TaskToTask"
  has_many :parent_tasks, through: :parent_task_tables

  has_many :child_task_tables, foreign_key: :child_task_id, class_name: "TaskToTask"
  has_many :child_tasks, through: :child_task_tables
end

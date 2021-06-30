class TaskToTask < ApplicationRecord
  belongs_to :parent_task, class_name: "Task"
  belongs_to :child_task, class_name: "Task"
end


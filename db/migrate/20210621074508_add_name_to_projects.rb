class AddNameToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :name, :string
  end
end

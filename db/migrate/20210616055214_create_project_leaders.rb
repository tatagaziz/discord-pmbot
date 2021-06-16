class CreateProjectLeaders < ActiveRecord::Migration[6.1]
  def change
    create_table :project_leaders do |t|
      t.string :discord_username

      t.timestamps
    end
  end
end

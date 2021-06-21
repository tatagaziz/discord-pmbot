class RemoveDiscordIdColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :project_leaders, :discord_id
  end
end

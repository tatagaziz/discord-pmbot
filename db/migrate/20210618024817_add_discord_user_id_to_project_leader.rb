class AddDiscordUserIdToProjectLeader < ActiveRecord::Migration[6.1]
  def change
    add_column :project_leaders, :discord_user_id, :string
    change_column :servers, :discord_server_id, :string
  end
end

class AddServerIdToProjectLeaders < ActiveRecord::Migration[6.1]
  def change
    add_reference :project_leaders, :servers, foreign_key: true

    change_table :project_leaders do |t|
      t.rename :discord_username, :discord_id
    end
  end
end

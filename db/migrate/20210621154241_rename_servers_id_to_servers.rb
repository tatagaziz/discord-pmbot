class RenameServersIdToServers < ActiveRecord::Migration[6.1]
  def change
    change_table :project_leaders do |t|
      t.rename :servers_id, :server_id
    end
  end
end

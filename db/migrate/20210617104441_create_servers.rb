class CreateServers < ActiveRecord::Migration[6.1]
  def change
    create_table :servers do |t|
      t.integer :discord_server_id
      t.string :name

      t.timestamps
    end
  end
end

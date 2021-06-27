class Server < ApplicationRecord
  validates :discord_server_id, uniqueness: true
  has_many :project_leaders, dependent: :destroy
end

class ProjectLeader < ApplicationRecord
  validates :discord_user_id, uniqueness: { scope: :server_id }
  has_many :projects, dependent: :destroy
  has_one :server
end

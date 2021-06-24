class ProjectLeader < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_one :server
end

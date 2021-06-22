class Server < ApplicationRecord
  has_many :project_leaders, dependent: :destroy
end

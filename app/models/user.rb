class User < ApplicationRecord
  has_many :installations, dependent: :destroy
end

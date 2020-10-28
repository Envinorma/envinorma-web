class Installation < ApplicationRecord
  validates :name, :date, presence: true
end

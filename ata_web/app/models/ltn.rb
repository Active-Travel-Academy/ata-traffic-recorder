class Ltn < ApplicationRecord
  belongs_to :user
  has_many :journeys
  has_many :runs
end

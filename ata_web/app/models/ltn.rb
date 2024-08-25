class Ltn < ApplicationRecord
  belongs_to :user
  has_many :journeys
  has_many :runs
  validates :scheme_name, presence: true, length: {minimum: 3, maximum: 45},
                   uniqueness: {scope: :user}
  validates :default_lat, presence: true
  validates :default_lng, presence: true
end

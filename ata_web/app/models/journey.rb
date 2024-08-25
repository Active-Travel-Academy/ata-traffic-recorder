class Journey < ApplicationRecord
  self.inheritance_column = nil # type is used by the R program asker
  enum :type, { frequently_routed: 'frequently_routed', infrequently_routed: 'infrequently_routed', test_routing: 'test_routing' }
  belongs_to :ltn

  validates :type, presence: true

  def map_data
    {
      origin_lat: origin_lat, origin_lng: origin_lng,
      dest_lat: dest_lat, dest_lng: dest_lng,
      waypoint_lat: waypoint_lat, waypoint_lng: waypoint_lng,
    }
  end
end

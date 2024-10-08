class Journey < ApplicationRecord
  self.inheritance_column = nil # type is used by the R program asker
  enum :type, { frequently_routed: 'frequently_routed', infrequently_routed: 'infrequently_routed', test_routing: 'test_routing' }
  belongs_to :ltn

  has_many :journey_runs

  before_save :trim_name

  validates :type, :origin_lat, :origin_lng, :dest_lat, :dest_lng, presence: true

  attr_accessor :route_straight_away

  CREATE_PARAMS = %w[origin_lat origin_lng dest_lat dest_lng name].freeze
  def self.create_from_csv(file, scheme)
    transaction do
      CSV.foreach(file, headers: true) do |row|
        scheme.journeys.create!(row.to_h.transform_keys({"optional name" => "name"}).slice(*CREATE_PARAMS))
      end
    end
  end

  def self.enable_all!
    where(disabled: true).update_all(disabled: false, updated_at: Time.current)
  end

  def self.disable_all!
    where(disabled: false).update_all(disabled: true, updated_at: Time.current)
  end

  def display_name
    "#{name || 'Journey'} [#{id}]"
  end

  def map_data
    {
      origin_lat: origin_lat, origin_lng: origin_lng,
      dest_lat: dest_lat, dest_lng: dest_lng,
      waypoint_lat: waypoint_lat, waypoint_lng: waypoint_lng,
    }
  end

  private

  def trim_name
    self.name = self.name.strip[0,250] if self.name
  end
end

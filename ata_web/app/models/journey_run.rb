require 'csv'
class JourneyRun < ApplicationRecord
  belongs_to :journey
  belongs_to :run

  scope :without_overview_polyline, -> { select(column_names - %w[overview_polyline]) }


  def self.to_csv(from:, to:, ltn:, overview_polyline: false)
    throw(:invalid_input, "To: '#{to}' is not a date") unless to.is_a?(Date)
    throw(:invalid_input, "From: '#{from}' is not a date") unless from.is_a?(Date)
    throw(:invalid_input, "From: '#{from}' must be before To: '#{to}'") unless from < to
    throw(:invalid_input, "Can only ask for 1 month of data at a time") if from < to - 1.month
    journey_attrs = %w{origin_lat origin_lng dest_lat dest_lng}
    attributes = %w{run_id duration duration_in_traffic distance created_at}

    runs = all.joins(:journey, :run).includes(:journey, :run).where(journeys: {ltn: ltn}, runs: {time: [from..to]}).order(:run_id)
    if overview_polyline
      attributes.push("overview_polyline")
    else
      runs.without_overview_polyline
    end

    CSV.generate(headers: true) do |csv|
      csv << [ "scheme", "mode", "journey_id",  *journey_attrs, *attributes ]

      runs.each do |j_run|
        csv << [
          ltn.scheme_name,
          j_run.run.mode,
          j_run.attributes["journey_id"],
          *journey_attrs.map { |attr| j_run.journey.attributes[attr] },
          *attributes.map { |attr| j_run.attributes[attr] },
        ]
      end
    end
  end

  def map_data
    {
      line: overview_polyline
    }
  end
end

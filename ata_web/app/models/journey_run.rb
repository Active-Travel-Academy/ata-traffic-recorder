require 'csv'
class JourneyRun < ApplicationRecord
  belongs_to :journey
  belongs_to :run

  def self.to_csv(from:, to:, ltn:, overview_polyline: false)
    throw(:invalid_input, "To: '#{to}' is not a date") unless to.is_a?(Date)
    throw(:invalid_input, "From: '#{from}' is not a date") unless from.is_a?(Date)
    throw(:invalid_input, "From: '#{from}' must be before To: '#{to}'") unless from < to
    throw(:invalid_input, "Can only ask for 1 year of data at a time") if from < to - 1.year
    attributes = %w{journey_id run_id duration duration_in_traffic distance created_at} #customize columns here
    attributes.push("overview_polyline") if overview_polyline

    runs = all.joins(:journey).where(journeys: {ltn: ltn}, created_at: [from..to])

    CSV.generate(headers: true) do |csv|
      csv << attributes

      runs.each do |run|
        csv << attributes.map{ |attr| run.attributes[attr] }
      end
    end
  end
end

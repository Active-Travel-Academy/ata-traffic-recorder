class AddCreatedAtIndexToJourneyRuns < ActiveRecord::Migration[7.1]
  def change
    add_index :journey_runs, :created_at
  end
end

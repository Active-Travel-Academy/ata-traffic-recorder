class AddTimestampsToJourneys < ActiveRecord::Migration[7.1]
  def change
    add_timestamps :journeys, null: false, default: Time.at(0)
    change_column_default :journeys, :created_at, nil
    change_column_default :journeys, :updated_at, nil
  end
end

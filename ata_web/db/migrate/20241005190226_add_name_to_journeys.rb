class AddNameToJourneys < ActiveRecord::Migration[7.1]
  def change
    add_column :journeys, :name, :string
  end
end

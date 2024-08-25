class AddDefaultLatLngToLtns < ActiveRecord::Migration[7.1]
  def change
    add_column :ltns, :default_lat, :float
    add_column :ltns, :default_lng, :float
  end
end

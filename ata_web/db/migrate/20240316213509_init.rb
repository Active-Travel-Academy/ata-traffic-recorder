class Init < ActiveRecord::Migration[7.1]
  def change
    create_enum "journey_type", ["frequently_routed", "infrequently_routed", "test_routing"]
    create_enum "run_mode", ["driving", "walking", "bicycling"]

    create_table "journey_runs", force: :cascade do |t|
      t.bigint "journey_id", null: false
      t.bigint "run_id", null: false
      t.integer "duration", null: false
      t.integer "duration_in_traffic"
      t.integer "distance", null: false
      t.jsonb "overview_polyline", null: false
      t.timestamptz "created_at", default: -> { "now()" }
      t.index ["journey_id"], name: "journey_runs_journey_id"
      t.index ["run_id"], name: "journey_runs_run_id"
    end

    create_table "journeys", force: :cascade do |t|
      t.bigint "ltn_id", null: false
      t.decimal "origin_lat", precision: 11, scale: 8, null: false
      t.decimal "origin_lng", precision: 11, scale: 8, null: false
      t.decimal "dest_lat", precision: 11, scale: 8, null: false
      t.decimal "dest_lng", precision: 11, scale: 8, null: false
      t.boolean "disabled", default: false, null: false
      t.decimal "waypoint_lat", precision: 11, scale: 8
      t.decimal "waypoint_lng", precision: 11, scale: 8
      t.enum "type", default: "test_routing", null: false, enum_type: "journey_type"
      t.index ["ltn_id"], name: "journeys_ltn_id", where: "(NOT disabled)"
      t.index ["type"], name: "journeys_type"
      t.check_constraint "waypoint_lat IS NULL AND waypoint_lng IS NULL OR waypoint_lat IS NOT NULL AND waypoint_lng IS NOT NULL", name: "both_or_neither_waypoints"
    end

    create_table "ltns", force: :cascade do |t|
      t.string "scheme_name", null: false
    end

    create_table "runs", force: :cascade do |t|
      t.bigint "ltn_id", null: false
      t.timestamptz "time", default: -> { "now()" }, null: false
      t.timestamptz "finished_at", default: -> { "now()" }
      t.enum "mode", default: "driving", null: false, enum_type: "run_mode"
      t.index ["ltn_id"], name: "runs_ltn_id"
      t.index ["mode"], name: "runs_mode"
    end

    add_foreign_key "journey_runs", "journeys", name: "journey_runs_journey_id"
    add_foreign_key "journey_runs", "runs", name: "journey_runs_run_id"
    add_foreign_key "journeys", "ltns", name: "journeys_ltn_id"
    add_foreign_key "runs", "ltns", name: "runs_ltn_id"
  end
end

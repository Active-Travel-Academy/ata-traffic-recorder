library(rollbar)
rollbar.attach()

library(googleway)
library(RPostgres)
library(DBI)
library(jsonlite)

con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("LTN_PGHOST"),
  dbname = 'ltns',
  user = Sys.getenv("LTN_PGUSER"),
  password = Sys.getenv("LTN_PGPASSWORD")
)

set_key(Sys.getenv("GOOGLE_API_KEY"))

# # Our default data
#
#
# con <- dbConnect(
#   RPostgres::Postgres(),
#   host = Sys.getenv("LTN_PGHOST"),
#   dbname = 'ltns',
#   user = Sys.getenv("LTN_ASKER_PGUSER"),
#   password = Sys.getenv("LTN_ASKER_PGPASSWORD")
# )
# res <- dbSendQuery(con, "INSERT INTO ltns (scheme_name) VALUES ('testing')")
# dbClearResult(res)
# res <- dbSendQuery(con,
#             "
#   INSERT INTO journeys (origin_lat, origin_lng, dest_lat, dest_lng, ltn_id)
#   VALUES
#   (51.444084,-0.085219145,51.451654,-0.096039176, 1),
#   (51.43953,-0.09780407,51.436982,-0.094408393, 1),
#   (51.442025,-0.096731186,51.436982,-0.094408393, 1)"
# )
# dbClearResult(res)


google_store_resp <- function(resp, run_id, journey_id){
  leg <- resp$routes$legs[[1]]
  journey_run_insert <- dbSendQuery(
    con,
    "INSERT INTO journey_runs (journey_id, run_id, duration, duration_in_traffic, distance, overview_polyline)
      VALUES ($1, $2, $3, $4, $5, $6)",
    params = list(
      journey_id, run_id, leg$duration$value,
      leg$duration_in_traffic$value, leg$distance$value,
      toJSON(decode_pl(resp$routes$overview_polyline$points), dataframe='values')
    )
  )
  dbClearResult(journey_run_insert)
}

tomtom_store_resp <- function(resp, run_id, journey_id){
  summary <- resp$routes$summary
  journey_run_insert <- dbSendQuery(
    con,
    "INSERT INTO tomtom_journey_runs (
      journey_id,
      run_id,
      traffic_delay_in_seconds,
      travel_time_in_seconds,
      live_traffic_incidents_travel_time_in_seconds,
      historic_traffic_travel_time_in_seconds,
      length_in_meters,
      overview_polyline
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",

    params = list(
      journey_id, run_id,
      summary$trafficDelayInSeconds, summary$travelTimeInSeconds,
      summary$liveTrafficIncidentsTravelTimeInSeconds, summary$historicTrafficTravelTimeInSeconds,
      summary$lengthInMeters,
      toJSON(resp$routes$legs[[1]]$points[[1]], dataframe='values')
    )
  )
  dbClearResult(journey_run_insert)
}

tomtom_direction_call <- function(journey) {
  req <- httr::GET(
    "https://api.tomtom.com/",
    path= paste0("routing/1/calculateRoute/", journey$origin_lat, ",", journey$origin_lng, ":", journey$dest_lat, ",", journey$dest_lng , "/json"),
    query = list(
      computeBestOrder = "false",
      computeTravelTimeFor = "all",
      computeTravelTimeFor = "traffic",
      departAt = "now",
      traffic = "true",
      avoid = "unpavedRoads",
      travelMode = "car",
      vehicleCommercial = "false",
      key = Sys.getenv("TOMTOM_API_KEY")
    ),
    httr::add_headers(Accept = "application/json")
  )
  httr::stop_for_status(req)
  status <- httr::http_status(req)
  if (status$reason != "OK" ) {
    rollbar.info("Tomtom error", list(message = status$message, journey_id = journey$id))
    return(NULL)
  }

  content <- httr::content(req, as = "text", encoding = "UTF-8")

  fromJSON(content)
}

res <- dbSendQuery(con, "SELECT id from ltns")
ltn_ids <- dbFetch(res)$id
dbClearResult(res)

for(n in 1:length(ltn_ids)){
  ltn_id <- as.integer(ltn_ids[n])
  journeys_query <- dbSendQuery(
    con,
    "SELECT id, origin_lat, origin_lng, dest_lat, dest_lng FROM journeys WHERE disabled = FALSE AND ltn_id = $1",
    params = ltn_id
  )
  journeys <- dbFetch(journeys_query)
  dbClearResult(journeys_query)
  run_insert <- dbSendQuery(con, "INSERT INTO runs (ltn_id) VALUES ($1) RETURNING id", params = ltn_id)
  run_id <- as.integer(dbFetch(run_insert)$id)
  dbClearResult(run_insert)
  if(nrow(journeys) == 0) {
    next
  }
  for(journey_n in 1:nrow(journeys)){
    journey <- journeys[journey_n,]
    google_resp <- google_directions(
      origin = c(journey$origin_lat,journey$origin_lng),
      destination = c(journey$dest_lat, journey$dest_lng),
      departure_time ='now'
    )
    google_store_resp(google_resp, run_id, journey$id)
    tomtom_retries <- 2
    while (tomtom_retries > 0) {
      tomtom_resp <- tomtom_direction_call(journey)
      if (!is.null(tomtom_resp)) {
        tomtom_store_resp(tomtom_resp, run_id, journey$id)
        break()
      }
      tomtom_retries = tomtom_retries - 1
    }
  }
}

journeys_missing_distances_query <- dbSendQuery(
  con,
  "SELECT journeys.* FROM journeys
  LEFT JOIN distances ON distances.journey_id = journeys.id
  WHERE journeys.disabled = FALSE AND distances.id IS NULL"
)
journeys_missing_distances <- dbFetch(journeys_missing_distances_query)
dbClearResult(journeys_missing_distances_query)
if(nrow(journeys_missing_distances) != 0) {
  for(journey_n in 1:nrow(journeys_missing_distances))
  {
    journey <- journeys_missing_distances[journey_n,]
    walk_resp <- google_directions(
      origin = c(journey$origin_lat,journey$origin_lng),
      destination = c(journey$dest_lat, journey$dest_lng),
      mode= "walking"
    )
    walk_leg <- walk_resp$routes$legs[[1]]

    bicycle_resp <- google_directions(
      origin = c(journey$origin_lat,journey$origin_lng),
      destination = c(journey$dest_lat, journey$dest_lng),
      mode= "bicycling"
    )
    bicycle_leg <- bicycle_resp$routes$legs[[1]]

    distance_insert <- dbSendQuery(
      con,
      "INSERT INTO distances
      (
        journey_id,
        walk_distance, bicycle_distance,
        walk_overview_polyline, bicycle_overview_polyline
      )
      VALUES ($1, $2, $3, $4, $5)",
      params = list(
        journey$id,
        walk_leg$distance$value, bicycle_leg$distance$value,
        toJSON(decode_pl(walk_resp$routes$overview_polyline$points), dataframe='values'),
        toJSON(decode_pl(bicycle_resp$routes$overview_polyline$points), dataframe='values')
      )
    )
    dbClearResult(distance_insert)
  }
}

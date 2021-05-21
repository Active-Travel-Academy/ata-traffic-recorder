library(rollbar)
rollbar.attach()

journey_args = commandArgs(trailingOnly=TRUE)

if (length(journey_args) == 1) {
  journey_args[2] = "driving"
}

library(googleway)
library(RPostgres)
library(DBI)
library(jsonlite)
library(glue)

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
#   INSERT INTO journeys (origin_lat, origin_lng, dest_lat, dest_lng, ltn_id, waypoint_lat, waypoint_lng)
#   VALUES
#   (51.444084,-0.085219145,51.451654,-0.096039176, 1, NULL, NULL),
#   (51.43953,-0.09780407,51.436982,-0.094408393, 1, NULL, NULL),
#   (51.442025,-0.096731186,51.436982,-0.094408393, 1, 51.442025, -0.094408393)"
# )
# dbClearResult(res)


google_store_resp <- function(resp, run_id, journey_id){
  leg <- resp$routes$legs[[1]]
  if (is.null(leg$duration_in_traffic)){
    duration_in_traffic <- list(NULL)
  } else {
    duration_in_traffic <- leg$duration_in_traffic$value
  }
  journey_run_insert <- dbSendQuery(
    con,
    "INSERT INTO journey_runs (journey_id, run_id, duration, duration_in_traffic, distance, overview_polyline)
      VALUES ($1, $2, $3, $4, $5, $6)",
    params = list(
      journey_id, run_id, leg$duration$value,
      duration_in_traffic, leg$distance$value,
      toJSON(decode_pl(resp$routes$overview_polyline$points), dataframe='values')
    )
  )
  dbClearResult(journey_run_insert)
}

res <- dbSendQuery(con, "SELECT id from ltns")
ltn_ids <- dbFetch(res)$id
dbClearResult(res)

for(n in 1:length(ltn_ids)){
  ltn_id <- as.integer(ltn_ids[n])
  journeys_query <- dbSendQuery(
    con,
    "SELECT id, origin_lat, origin_lng, dest_lat, dest_lng, waypoint_lat, waypoint_lng FROM journeys WHERE disabled = FALSE AND ltn_id = $1 AND type = $2",
    params = list(ltn_id, journey_args[1])
  )
  journeys <- dbFetch(journeys_query)
  dbClearResult(journeys_query)
  if(nrow(journeys) == 0) {
    next
  }
  run_insert <- dbSendQuery(
    con, "INSERT INTO runs (ltn_id, mode) VALUES ($1, $2) RETURNING id",
    params = list(ltn_id, journey_args[2])
  )
  run_id <- as.integer(dbFetch(run_insert)$id)
  dbClearResult(run_insert)
  for(journey_n in 1:nrow(journeys)){
    journey <- journeys[journey_n,]
    waypoints <- NULL
    if (!is.na(journey$waypoint_lat)) {
      waypoints <- list(via = c(journey$waypoint_lat, journey$waypoint_lng))
    }
    tryCatch(
      {
        google_resp <- google_directions(
          origin = c(journey$origin_lat,journey$origin_lng),
          destination = c(journey$dest_lat, journey$dest_lng),
          departure_time ='now',
          waypoints = waypoints,
          mode = journey_args[2]
        )
        google_store_resp(google_resp, run_id, journey$id)
      }
      , error = function(e) {
        e.type <- 'google'
        e.journey_id <- journey$id
        rollbar.info(e)
      }
    )
  }
  if (identical(journey_args[3], "disable_after")) {
    disable_journeys_sql <- glue_sql(
      "UPDATE journeys SET disabled = TRUE WHERE id IN ({journey_ids*})",
      journey_ids = journeys$id,
      .con = con
    )
    disable_journeys_query <- dbSendQuery(con, disable_journeys_sql)
    dbClearResult(disable_journeys_query)
  }
}

dbDisconnect(con)

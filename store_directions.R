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


store_resp <- function(google_resp, run_id, journey_id){
  leg <- resp$routes$legs[[1]]
  journey_run_insert <- dbSendQuery(
    con,
    "INSERT INTO journey_runs (journey_id, run_id, duration, duration_in_traffic, distance, overview_polyline)
      VALUES ($1, $2, $3, $4, $5, $6)",
    params = list(
      journey$id, run_id, leg$duration$value,
      leg$duration_in_traffic$value, leg$distance$value,
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
    "SELECT id, origin_lat, origin_lng, dest_lat, dest_lng FROM journeys WHERE disabled = FALSE AND ltn_id = $1",
    params = ltn_id
  )
  journeys <- dbFetch(journeys_query)
  dbClearResult(journeys_query)
  run_insert <- dbSendQuery(con, "INSERT INTO runs (ltn_id, time) VALUES ($1, NOW()) RETURNING id", params = ltn_id)
  run_id <- as.integer(dbFetch(run_insert)$id)
  dbClearResult(run_insert)
  for(journey_n in 1:nrow(journeys)){
    journey <- journeys[journey_n,]
    resp <- google_directions(
      origin = c(journey$origin_lat,journey$origin_lng),
      destination = c(journey$dest_lat, journey$dest_lng),
      departure_time ='now'
    )
    store_resp(resp, run_id, journey$id)
  }
}

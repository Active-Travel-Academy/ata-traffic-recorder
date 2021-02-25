# Low Traffic Neighbourhoods (LTNs) - Traffic recorder

We want to pool live traffic data from google for specific routes around LTNs to identify
any impacts of LTNs on journey times.  The code to call Google's direction
API is in R and the data is stored in a SQL database (postgres - as we might want to
store geographical data using postgis later).

The database has quite tight access control as there is no graphical interface.

# Active Travel Academy (ATA) - Traffic recorder

We want to pull live traffic data from google for specific routes around Low Traffic Neighbourhoods (LTNs)
to identify any impacts of LTNs on journey times.  The code to call Google's direction
API is in R and the data is stored in a SQL database (postgres - as we might want to
store geographical data using postgis later).

The database has quite tight access control as there is no graphical interface.

# Setup

Create a postgres database and create the three roles:

```sql
CREATE DATABASE ltns;
CREATE ROLE shared_role NOLOGIN;
CREATE ROLE r_program IN ROLE shared_role PASSWORD "..." LOGIN;
CREATE ROLE asker IN ROLE shared_role PASSWORD "..." LOGIN;
```
then import the schema:
```
psql -U postgres ltns < ata.sql
```
(assuming you're superuser is postgres)

Copy the `.Renviron.sample` to `.Renviron` and fill in with correct details.

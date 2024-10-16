class VacuumAndAnalyzeLargeTables < ActiveRecord::Migration[7.1]
  def up
    # Store more stats to better help the query planner
    execute "ALTER TABLE ONLY public.journey_runs ALTER COLUMN journey_id SET STATISTICS 10000;"
    execute "ALTER TABLE ONLY public.journey_runs ALTER COLUMN run_id SET STATISTICS 1000;"

    # This will trigger a table to vacuum and analyze based on a fixed threshold (1000 or 500) and not a factor of the table size:
    %w[journey_runs runs].each do |table|
      execute "ALTER TABLE public.#{table} SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 1000, autovacuum_analyze_scale_factor = 0, autovacuum_analyze_threshold = 500)"
    end
  end
end

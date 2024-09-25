class JourneyRunDownloadsController < ApplicationController
  before_action :set_ltn

  def new
  end

  def create
    from_date =
      begin
        Date.iso8601(permitted_params[:from])
      rescue Date::Error
        permitted_params[:from]
      end

    to_date =
      begin
        Date.iso8601(permitted_params[:to])
      rescue Date::Error
        permitted_params[:to]
      end

    invalid_input = catch(:invalid_input) do
      send_data JourneyRun.to_csv(
        from: from_date, to: to_date,
        ltn: @ltn,
        overview_polyline: ActiveModel::Type::Boolean.new.cast(permitted_params[:overview_polyline])
      ), filename: "#{@ltn.scheme_name}-#{permitted_params[:from]}-#{permitted_params[:to]}-journey-runs-.csv"
      return
    end
    redirect_to new_ltn_journey_run_download_path(@ltn), alert: invalid_input
  end

  private

  def set_ltn
    @ltn = current_user.ltns.find(params[:ltn_id])
  end

  def permitted_params
    params.require(:data_download).permit(:from, :to, :overview_polyline)
  end
end

class JourneyRunDownloadsController < ApplicationController
  before_action :set_ltn, only: %i[ new create ]

  def new
  end

  def create
    send_data JourneyRun.to_csv(
      from: Date.iso8601(permitted_params[:from]), to: Date.iso8601(permitted_params[:to]), ltn: @ltn
    ), filename: "#{@ltn.scheme_name}-#{permitted_params[:from]}-#{permitted_params[:to]}-journey-runs-#{}.csv"
  end

  private

  def set_ltn
    @ltn = current_user.ltns.find(params[:ltn_id])
  end

  def permitted_params
    params.require(:data_download).permit(:from, :to, :overview_polyline)
  end
end

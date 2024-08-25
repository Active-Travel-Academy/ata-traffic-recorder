class JourneysController < ApplicationController
  before_action :set_ltn, only: %i[ new create show ]

  def new
    @journey = @ltn.journeys.build
  end

  def show
    @journey = @ltn.journeys.find(params[:id])
  end

  def create
    @journey = @ltn.journeys.build(permitted_params)
    if @journey.save
      redirect_to @ltn, notice: "Journey successfully created."
    else
      render :new
    end
  end

  private

  def set_ltn
    @ltn = current_user.ltns.find(params[:ltn_id])
  end

  def permitted_params
    params.require(:journey).permit(:type, :origin_lat, :origin_lng, :dest_lat, :dest_lng)
  end
end

class JourneysUploadsController < ApplicationController
  before_action :set_ltn

  def create
    Journey.create_from_csv(params[:journeys_upload][:file], @ltn)
    redirect_to @ltn, notice: "Journeys successfully created."
  end

  private

  def set_ltn
    @ltn = current_user.ltns.find(params[:ltn_id])
  end
end

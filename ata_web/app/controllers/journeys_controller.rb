class JourneysController < ApplicationController
  before_action :set_ltn

  def new
    @journey = @ltn.journeys.build
  end

  def show
    journey
  end

  def create
    @journey = @ltn.journeys.build(permitted_params)
    if @journey.save
      redirect_to @ltn, notice: "Journey successfully created."
    else
      render :new
    end
  end

  def update
    if journey.update!(update_params)
      if update_params.keys.include? "disabled"
        flash.now[:notice] = "Journey [#{journey.id}] is now #{journey.disabled ? 'disabled' : 'enabled'}"
      end
    else
      flash.now[:alert] = "Something went wrong"
    end

    respond_to do |format|
      format.html { redirect_to journey }
      format.turbo_stream # Renders update.turbo_stream.erb
    end
  end


  def destroy
    if journey.destroy
      redirect_to ltn_path(@ltn), notice: "Journey was successfully destroyed.", status: :see_other
    else
      redirect_to journey, notice: "Journey could not be destroyed, it might have been run", status: :see_other
    end
  end

  private

  def journey
    @journey ||= @ltn.journeys.find(params[:id])
  end

  def set_ltn
    @ltn = current_user.ltns.find(params[:ltn_id])
  end

  def permitted_params
    params.require(:journey).permit(:type, :origin_lat, :origin_lng, :dest_lat, :dest_lng)
  end

  def update_params
    params.require(:journey).permit(:type, :disabled)
  end
end

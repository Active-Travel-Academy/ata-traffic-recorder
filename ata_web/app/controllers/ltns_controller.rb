class LtnsController < ApplicationController
  before_action :set_ltn, only: %i[ show edit update destroy ]

  # GET /ltns
  def index
    @ltns = current_user.ltns
  end

  # GET /ltns/1
  def show
  end

  # GET /ltns/new
  def new
    @ltn = Ltn.new
  end

  # GET /ltns/1/edit
  def edit
  end

  # POST /ltns
  def create
    @ltn = current_user.ltns.build(ltn_params)

    if @ltn.save
      redirect_to @ltn, notice: "Scheme was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ltns/1
  def update

    if @ltn.update(ltn_params)
      redirect_to @ltn, notice: "Ltn was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /ltns/1
  def destroy
    @ltn.destroy!
    redirect_to ltns_url, notice: "Ltn was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ltn
      @ltn = current_user.ltns.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ltn_params
      params.require(:ltn).permit(:scheme_name, :default_lat, :default_lng)
    end
end

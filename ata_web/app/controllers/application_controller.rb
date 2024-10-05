class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pagy::Backend
end

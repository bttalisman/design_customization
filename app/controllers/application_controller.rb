# Application Controller
class ApplicationController < ActionController::Base

  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_logged_in_user

  # Return the shopify id saved on the session
  def get_logged_in_user
    id = session[ :shopify_id ]
    @user = User.find_by( :shopify_id => id ) if !id.nil?
  end

end

# Home Controller
class HomeController < ApplicationController

  include ApplicationHelper
  include HomeHelper

  def index
  end

  def tools
    Rails.logger.info 'home_controller - tools() - params: ' + params.to_s
    
  end


  def log_out
    Rails.logger.info 'home_controller - log_out();'
    session[ :shopify_id ] = nil
    render nothing: true
  end

  def log_in
  end

  def process_log_in
    id = params[ :shopify_id ]
    email = params[ :email ]

    Rails.logger.info 'home_controller - process_log_in() - id: ' + id.to_s
    Rails.logger.info 'home_controller - process_log_in() - email: ' + email.to_s

    if id
      session[ :shopify_id ] = id
    else
      user = User.find_by( email: email )
      Rails.logger.info 'home_controller - process_log_in() - user: ' + user.to_s
      session[ :shopify_id ] = user.shopify_id
    end

    render nothing: true
  end

  def update_users
    do_update_users
    render nothing: true
  end

  def trans_butt
    @colors = Color.all
    @text_color = @colors.first
  end

  def trans_butt_settings
    make_trans_butt_version( params )
    redirect_to design_templates_url
  end

end

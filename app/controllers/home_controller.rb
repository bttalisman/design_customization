# Home Controller
class HomeController < ApplicationController

  include ApplicationHelper
  include HomeHelper

  def index
  end

  def tools
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

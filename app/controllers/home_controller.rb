# Home Controller
class HomeController < ApplicationController

  include ApplicationHelper
  include HomeHelper

  def index
  end

  def tools
  end

  def trans_butt
  end

  def trans_butt_settings
    make_trans_butt_version( params )
    redirect_to design_templates_url
  end

end

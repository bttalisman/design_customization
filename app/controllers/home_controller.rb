# Home Controller
class HomeController < ApplicationController

  include ApplicationHelper

  def index
  end

  def tools
    check_insta_token
  end
end

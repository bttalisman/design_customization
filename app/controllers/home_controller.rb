# Home Controller
class HomeController < ApplicationController
  def index
  end

  def tools
  end

  def remote_run
    logger.info 'HOMECONTROLLER - remote_run()'
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @@local_host = nil

  def get_local_host
    if @@local_host == nil then
      @@local_host = request.protocol + request.host + ':' + request.port.to_s
      logger.info "ApplicationController - GET_LOCAL_HOST - Setting localhost to: " + @@local_host
    end
    @@local_host
  end

  helper_method :get_local_host


end

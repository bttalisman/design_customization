# This is the top level controller for the project
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @local_host = nil

  def local_host
    if @local_host.nil?
      @local_host = request.protocol + request.host + ':' + request.port.to_s
      # logger.info 'ApplicationController - LOCAL_HOST - Setting localhost'\
      # ' to: ' + @@local_host
    end
    @local_host
  end

  helper_method :local_host
end

# Application Controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def git_fetch
    Rails.logger.info( 'ApplicationController - git_fetch()' )
    sys_com = 'git fetch'
    success = system( sys_com )
    Rails.logger.info( 'ApplicationController - git_fetch() success: '\
      + success.to_s )
    render nothing: true
  end
end

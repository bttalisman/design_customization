# Application Controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # This action is invoked to remotely cause the rails server to get the latest
  # code from the git repo.
  def git_fetch
    sys_com = 'git fetch'
    success = system( sys_com )
    Rails.logger.info( 'ApplicationController - git_fetch() sys_com: '\
      + sys_com.to_s )
    Rails.logger.info( 'ApplicationController - git_fetch() success: '\
      + success.to_s )

    sys_com = 'git merge -m "Remotely requested merge."'
    success = system( sys_com )
    Rails.logger.info( 'ApplicationController - git_fetch() sys_com: '\
      + sys_com.to_s )
    Rails.logger.info( 'ApplicationController - git_fetch() success: '\
      + success.to_s )

    render nothing: true
  end
end

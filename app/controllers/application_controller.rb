# Application Controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end


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

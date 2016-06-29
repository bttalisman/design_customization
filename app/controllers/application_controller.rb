# Application Controller
class ApplicationController < ActionController::Base

  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def clear_token
    Rails.logger.info 'ApplicationController - clear_token()'
    clear_insta_token
  end

  # This action is hit by the Instagram authentication endpoint
  def process_code
    Rails.logger.info 'ApplicationController - process_code()'

    # code is passed as a query parameter, it must be passed on to the
    # instagram API in return for a token
    code = request.query_parameters[ 'code' ]
    Rails.logger.info 'ApplicationController - process_code() - code: '\
      + code.to_s

    if !code.nil?
      # code was passed, get the token from instagram

      uri = URI( 'https://api.instagram.com/oauth/access_token' )

      redirect_uri = local_host + '/process_code'

      res = Net::HTTP.post_form( uri,
                                 'client_id' => '2b45daba4e154a6cb20060193db7ebfc',
                                 'client_secret' => 'a9260a99b47f4caab4eecf0f86cf8241',
                                 'grant_type' => 'authorization_code',
                                 'redirect_uri' => redirect_uri,
                                 'code' => code )

      Rails.logger.info 'ApplicationController - process_code() - res: '\
        + res.inspect
      Rails.logger.info 'ApplicationController - process_code() - res.body: '\
        + res.body.to_s

      if json?( res.body )
        hash = JSON.parse res.body
        token = hash[ 'access_token' ]
        session[ :insta_token ] = token
      end
    end

    render 'home/tools'

  end # end processcode

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

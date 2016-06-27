# ReplacementImages Controller
class ReplacementImagesController < ApplicationController
  include ApplicationHelper

  class FailedInstagramConnection < StandardError
  end

  rescue_from FailedInstagramConnection, with: :clear_token

  def new
  end

  def create
  end

  def fetch
    Rails.logger.info 'ReplacementImagesController - fetch()'

    token = session[ :insta_token ]
    Rails.logger.info 'ReplacementImagesController - fetch() - token: ' + token.to_s

    query = 'wood'
    uristring = 'https://api.instagram.com/v1/tags/' + query + '/media/recent?access_token=' + token.to_s

    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'RAISING FailedInstagramConnection'
      raise FailedInstagramConnection
    end

    body = JSON.parse res.body if json?( res.body )

    Rails.logger.info 'body: ' + JSON.pretty_generate( body )

    render nothing: true
  end



  def clear_token
    session[:insta_token] = nil
    url = 'http://api.instagram.com/oauth/authorize/?client_id=2b45daba4e154a6cb20060193db7ebfc&redirect_uri=' + local_host + '/process_code&response_type=code'
    Rails.logger.info 'ReplacementImagesController - clear_token() - url: ' + url.to_s

    redirect_to "http://www.google.com"
  end



  def process_code

    Rails.logger.info 'ReplacementImagesController - process_code()'

    # code is passed as a query parameter, it must be passed on to the instagram API in return for a token
    vars = request.query_parameters
    code = vars['code']
    Rails.logger.info 'GOT code!! - code: ' + code.to_s


    if code != nil then

      # code was passed, get the token from instagram

      uri = URI('http://api.instagram.com/oauth/access_token')

      redirect_uri = local_host + '/process_code'

      res = Net::HTTP.post_form(uri, 'client_id' => '2b45daba4e154a6cb20060193db7ebfc',
                                'client_secret' => 'a9260a99b47f4caab4eecf0f86cf8241',
                                'grant_type' => 'authorization_code', 'redirect_uri' => redirect_uri,
                                'code' => code)


      Rails.logger.info 'GOT token!! - res.body: ' + res.body.to_s

      if json?( res.body ) then
        hash = JSON.parse res.body
        token = hash['access_token']
      end
      session[:insta_token] = token

    else

      # instagram API didn't pass us a code.  Something is wrong.

    end

    render nothing: true

  end   # end def processcode








  private

  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end
end

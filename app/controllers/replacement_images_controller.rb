# ReplacementImages Controller
class ReplacementImagesController < ApplicationController
  include ApplicationHelper

  class FailedInstagramConnection < StandardError
  end

  rescue_from FailedInstagramConnection, with: :cleartoken

  def new
  end

  def create
  end

  def fetch
    Rails.logger.info 'ReplacementImagesController - fetch()'

    token = session[ :insta_token ]
    query = 'wood'
    uristring = 'https://api.instagram.com/v1/tags/' + query + '/media/recent?access_token=' + token.to_s

    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'RAISING FailedInstagramConnection'
      raise FailedInstagramConnection
    end

    body = JSON.parse res.body if JSON.is_json?( res.body )

    Rails.logger.info 'body: ' + JSON.pretty_generate( body )

    render nothing: true
  end



  def clear_token

    logger.info 'ReplacementImagesController - clear_token()'

    session[:insta_token] = nil
    redirect_to 'https://api.instagram.com/oauth/authorize/?client_id=2b45daba4e154a6cb20060193db7ebfc&redirect_uri=http://armory.bombsheller.net:3000/processcode&response_type=code'
  end



  def process_code

    Rails.logger.info 'ReplacementImagesController - process_code()'

    # code is passed as a query parameter, it must be passed on to the instagram API in return for a token
    vars = request.query_parameters
    code = vars['code']


    if code != nil then

      # code was passed, get the token from instagram

      uri = URI('https://api.instagram.com/oauth/access_token')

      redirect_uri = local_host + '/processcode'

      res = Net::HTTP.post_form(uri, 'client_id' => '2b45daba4e154a6cb20060193db7ebfc',
                                'client_secret' => 'a9260a99b47f4caab4eecf0f86cf8241',
                                'grant_type' => 'authorization_code', 'redirect_uri' => redirect_uri,
                                'code' => code)


      if JSON.is_json?( res.body ) then
        hash = JSON.parse res.body
        token = hash['access_token']
      end
      session[:insta_token] = token

    else

      # instagram API didn't pass us a code.  Something is wrong.

    end

    redirect_to action: :index

  end   # end def processcode








  private

  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end
end

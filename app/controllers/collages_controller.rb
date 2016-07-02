class CollagesController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
  end

  def fetch
    Rails.logger.info 'CollagesController - fetch()'

    token = session[ :insta_token ]
    Rails.logger.info 'CollagesController - fetch() - token: ' + token.to_s

    uristring = 'https://api.instagram.com/v1/users/self/media/recent/?access_token=' + token.to_s


    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'Instagram fetch failure.'
    end

    body = JSON.parse res.body if json?( res.body )
    Rails.logger.info 'body: ' + JSON.pretty_generate( body )

    render nothing: true
  end

  private

  def collage_params
    params.require( :collage ).permit( )
  end
end

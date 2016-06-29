# ReplacementImages Controller
class ReplacementImagesController < ApplicationController
  include ApplicationHelper


  def new
  end

  def create
  end

  def fetch
    Rails.logger.info 'ReplacementImagesController - fetch()'

    token = session[ :insta_token ]
    Rails.logger.info 'ReplacementImagesController - fetch() - token: ' + token.to_s

    uristring = 'https://api.instagram.com/v1/users/self/media/recent/?access_token=' + token.to_s


    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'RAISING FailedInstagramConnection'
    end

    body = JSON.parse res.body if json?( res.body )

    Rails.logger.info 'body: ' + JSON.pretty_generate( body )

    render nothing: true
  end

  private

  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end
end

# ReplacementImages Controller
class ReplacementImagesController < ApplicationController
  include ApplicationHelper

  before_action :check_insta_token

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

  private

  def check_insta_token
    get_insta_token if session[:insta_token].nil?
  end

  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end
end

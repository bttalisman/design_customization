class CollagesController < ApplicationController

  include ApplicationHelper

  rescue_from FailedInstagramConnection, with: :cleartoken

  class FailedInstagramConnection < StandardError
  end

  @@ngrok_host = 'https://6ff06513.ngrok.io'

  def processcode
    logger.info 'replacement_images_controller - processcode()'
    vars = request.query_parameters
    code = vars['code']

    if !code.nil?
      # code was passed, get the token from instagram

      uri = URI('https://api.instagram.com/oauth/access_token')
      redirect_uri = @@ngrok_host + '/processcode'

      res = Net::HTTP.post_form( uri, 'client_id' => '2b45daba4e154a6cb20060193db7ebfc', 'client_secret' => 'a9260a99b47f4caab4eecf0f86cf8241',
  'grant_type' => 'authorization_code', 'redirect_uri' => redirect_uri, 'code' => code)

      if JSON.is_json?( res.body )
        hash = JSON.parse res.body
        token = hash['access_token']
      end

      session[:insta_token] = token
    end

    redirect_to action: :index
  end

  # This method is called whenver a FailedInstagramConnection exception is thrown,
  # assuming that the problem is an expired token.
  def cleartoken
    logger.info 'replacement_images_controller - cleartoken()'
    session[:insta_token] = nil
    redirect_to @@ngrok_host + '/processcode'
#    redirect_to 'https://api.instagram.com/oauth/authorize/'\
#      + '?client_id=2b45daba4e154a6cb20060193db7ebfc&redirect_uri='\
#      + @@ngrok_host + '/processcode&response_type=code'
  end


  def fetch()
    fetch_pics( 'bob' )
  end

  private

  def fetch_pics( user_id )
    logger.info 'replacement_images_controller - fetch_pics()'
    pages_got = 0
    items_got = 0

    # get the instagram token from the session
    token = session[:insta_token]

    uristring = 'https://api.instagram.com/v1/users/' + user_id\
      + '/media/recent?access_token=' + token.to_s

    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    raise FailedInstagramConnection if !res.kind_of? Net::HTTPSuccess

    body = JSON.parse res.body if JSON.is_json?( res.body )

    if !body.nil?
      data = body['data']
      next_url = body['pagination']['next_url']
    end

    if !data.nil?

      pages_got += 1

      data.each { |pic|
        id = pic[ 'id' ]

      } # each pic

    end # data != nil

    while (next_url != nil) && (items_got < @@max_items_to_retrieve) do

      pages_got += 1
      uri = URI( next_url )
      res = Net::HTTP.get_response( uri )

      raise FailedInstagramConnection if !res.kind_of? Net::HTTPSuccess

      body = JSON.parse res.body if JSON.is_json?( res.body )

      data = body['data']
      next_url = body['pagination']['next_url']

      if !data.nil?

        data.each { |pic|
          break if items_got >= @@max_items_to_retrieve
          id = pic[ 'id' ]
          pic_tags = pic[ 'tags' ]
        } # each pic

      end # got data
    end # while there are more pages
  end
end

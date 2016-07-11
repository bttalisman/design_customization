# Collages Helper
module CollagesHelper
  require 'open-uri'
  include ApplicationHelper

  # This method is called after the collage is saved.  It creates a folder,
  # contacts Instagram and downloads images based on the query into that
  # folder.
  def build_collage_folder( collage )
    path = collage.path
    logger.info 'CollagesHelper - build_collage_folder() - path: ' + path.to_s
    FileUtils.mkdir_p( path ) unless File.directory?( path )
    fetch_content( collage )
  end

  # This method downloads images from Instagram and places them in the collage
  # folder.  If Instagram is an asshole, the query could be the URL of zip file
  # containing images.  I use miniMagick to reformat the image because jpgs
  # retrieved from Instagram cause errors in AI.
  def fetch_content( collage )
    token = session[ :insta_token ]
    path = collage.path
    query = collage.query
    Rails.logger.info 'CollagesHelper - fetch_content() - token: ' + token.to_s
    Rails.logger.info 'CollagesHelper - fetch_content() - path: ' + path.to_s
    Rails.logger.info 'CollagesHelper - fetch_content() - query: ' + query.to_s

    uristring = 'https://api.instagram.com/v1/users/self/media/recent/?access_token=' + token.to_s

    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'Instagram fetch failure.'
    else
      body = JSON.parse res.body if json?( res.body )
      #Rails.logger.info 'CollagesHelper - fetch_content() - body: ' + JSON.pretty_generate( body )

      index = 0
      body[ 'data' ].each { |item|
        url = item[ 'images' ][ 'standard_resolution' ][ 'url' ]
        Rails.logger.info 'CollagesHelper - fetch_content() - url: ' + url.to_s

        image = MiniMagick::Image.open( url )
        width = image.width
        height = image.height

        if( (height >= 500) && (width >= 500) )
          # if the image is big enough, we'll crop it and save it.

          x_offset = (width - 500) / 2
          y_offset = (height - 500) / 2

          crop_string = '500x500+' + x_offset.to_s + '+' + y_offset.to_s
          image.crop( crop_string )
          image.format 'png'

          # Any name will do, the AI script will just place all of the images
          # found in the collage folder.
          index += 1
          full_path = path + '/image_' + index.to_s + '.png'
          image.write( full_path )
        end
      }
    end
  end
end

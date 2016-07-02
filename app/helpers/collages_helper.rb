# Collages Helper
module CollagesHelper
  include ApplicationHelper



  # This method is called after the collage is saved.  It creates a folder,
  # contacts Instagram and downloads images based on the query into that
  # folder.
  def build_collage_folder( collage )

    app_config = Rails.application.config_for(:customization)
    collage_root = app_config[ 'path_to_collage_root' ]

#    path = @@path_to_collage_root + '/collage_' + self[:id].to_s
    path = collage_root + '/test_collage'
    logger.info 'CollagesHelper - build_collage_folder() - path: ' + path.to_s

    FileUtils.mkdir_p( path ) unless File.directory?( path )

    fetch_content( collage )
  end


  def fetch_content( collage )

    Rails.logger.info 'CollagesHelper - fetch_content() - collage: ' + collage.to_s

    token = session[ :insta_token ]
    Rails.logger.info 'CollagesHelper - fetch_content() - token: ' + token.to_s

    uristring = 'https://api.instagram.com/v1/users/self/media/recent/?access_token=' + token.to_s


    uri = URI( uristring )
    res = Net::HTTP.get_response(uri)

    if !res.is_a? Net::HTTPSuccess
      Rails.logger.info 'Instagram fetch failure.'
    end

    body = JSON.parse res.body if json?( res.body )
    Rails.logger.info 'CollagesHelper - fetch_content() - body: ' + JSON.pretty_generate( body )

    render nothing: true
  end

end

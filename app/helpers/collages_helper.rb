# Collages Helper
module CollagesHelper
  include ApplicationHelper
  include ImageHelper

  # This method is called after the collage is saved.  It creates a folder,
  # contacts Instagram and downloads images based on the query into that
  # folder.
  def build_collage_folder( collage )
    path = collage.path
    logger.info 'CollagesHelper - build_collage_folder() - path: ' + path.to_s
    FileUtils.mkdir_p( path ) unless File.directory?( path )
    fetch_content( collage )
  end

  # I use miniMagick to reformat the image because jpgs retrieved from
  # Instagram cause errors in AI.
  def crop_and_save_collage_image( image, index, path, collage )

    design_template = collage.version.design_template
    image_name = collage.image_name

    height = get_original_height( design_template, image_name )
    width = get_original_width( design_template, image_name )

    image = resize_with_crop( image, width.to_f, height.to_f )

    image.format 'png'
    # Any name will do, the AI script will just place all of the images
    # found in the collage folder.
    full_path = path + '/image_' + index.to_s + '.png'
    image.write( full_path )
    return true
  end

  def extract_insta_data( o, type )
    if type == 'user'
      data = o[ 'entry_data' ][ 'ProfilePage' ][ 0 ][ 'user' ][ 'media' ][ 'nodes' ]
      page_info = o[ 'entry_data' ][ 'ProfilePage' ][ 0 ][ 'user' ][ 'media' ][ 'page_info' ]
      max_id = page_info[ 'end_cursor' ]
      has_next_page = page_info[ 'has_next_page' ]
    else
      data = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'nodes' ]
      page_info = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'page_info' ]
      max_id = page_info[ 'end_cursor' ]
      has_next_page = page_info[ 'has_next_page' ]
    end
    return_data = { 'data' => data, 'max_id' => max_id, 'has_next_page' => has_next_page }
    return_data
  rescue NoMethodError
    Rails.logger.info 'collages_helper - extract_insta_data() - No Data!'
    nil
  end



  # This method downloads images from Instagram and places them in the collage
  # folder.
  def fetch_content( collage )

    app_config = Rails.application.config_for( :customization )
    path = collage.path
    query = collage.query
    if json?( query )
      query = JSON.parse( query )
      query_type = query[ 'instagram' ][ 'type' ]
      query_string = query[ 'instagram' ][ 'query_string' ]
    end
    max_items = app_config[ 'collages_max_items_to_retrieve' ]
    index = 0

    # the following code goes to instagram and scrapes image data from
    # the page.
    # create a headless browser
    b = Watir::Browser.new :phantomjs
    uri = 'https://www.instagram.com/explore/tags/' + query_string.to_s
    uri = 'https://www.instagram.com/' + query_string.to_s if query_type == 'user'
    b.goto uri

    # all data are stored on this page-level object.
    o = b.execute_script( 'return window._sharedData;')
    o = extract_insta_data( o, query_type )

    data = o[ 'data' ]
    has_next_page = o[ 'has_next_page' ]
    max_id = o[ 'max_id' ]

    data.each { |item|
      break if index >= max_items
      url = item[ 'thumbnail_src' ]
      image = MiniMagick::Image.open( url )
      index += 1 if crop_and_save_collage_image( image, index, path, collage )
    }

    while( has_next_page && (index < max_items) )
      uri = 'https://www.instagram.com/explore/tags/' + query_string.to_s\
        + '?&max_id=' + max_id.to_s
      uri = 'https://www.instagram.com/' + query_string.to_s + '?&max_id='\
        + max_id.to_s if query_type === 'user'
      b.goto uri
      o = b.execute_script( 'return window._sharedData;')
      o = extract_insta_data( o, query_type )
      data = o[ 'data' ]
      has_next_page = o[ 'has_next_page' ]
      max_id = o[ 'max_id' ]

      data.each { |item|
        break if index >= max_items
        url = item[ 'thumbnail_src' ]
        image = MiniMagick::Image.open( url )
        index += 1 if crop_and_save_collage_image( image, index, path, collage )
      }
    end
    b.close # IMPORTANT!
  rescue
    Rails.logger.info 'collages_helper - fetch_content() - Error scraping Instagram.'
    b.close
  end
end

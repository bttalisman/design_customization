# Collages Helper
module CollagesHelper
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

  # I use miniMagick to reformat the image because jpgs retrieved from
  # Instagram cause errors in AI.
  def crop_and_save_image( image, index, path )
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
      full_path = path + '/image_' + index.to_s + '.png'
      image.write( full_path )
      return true
    end
    return false
  end

  # This method downloads images from Instagram and places them in the collage
  # folder.
  def fetch_content( collage )
    app_config = Rails.application.config_for( :customization )
    path = collage.path
    query = collage.query
    max_items = app_config[ 'collages_max_items_to_retrieve' ]
    Rails.logger.info 'CollagesHelper - fetch_content() - path: ' + path.to_s
    Rails.logger.info 'CollagesHelper - fetch_content() - query: ' + query.to_s
    Rails.logger.info 'CollagesHelper - fetch_content() - max_items: '\
      + max_items.to_s

    index = 0
    # the following code goes to instagram and scrapes image data from
    # the page.

    # create a headless browser
    b = Watir::Browser.new :phantomjs
    uri = 'https://www.instagram.com/explore/tags/' + query + '?hl=en'
    b.goto uri

    # all data are stored on this page-level object.
    o = b.execute_script( 'return window._sharedData;')

    data = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'nodes' ]
    page_info = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'page_info' ]
    max_id = page_info[ 'end_cursor' ]
    has_next_page = page_info[ 'has_next_page' ]

    data.each { |item|
      break if index >= max_items
      url = item[ 'thumbnail_src' ]
      image = MiniMagick::Image.open( url )
      index += 1 if crop_and_save_image( image, index, path )
    }

    while( has_next_page && (index < max_items) )
      uri = 'https://www.instagram.com/explore/tags/bombsheller?hl=en&max_id='\
        + max_id.to_s
      b.goto uri
      o = b.execute_script( 'return window._sharedData;')

      data = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'nodes' ]
      page_info = o[ 'entry_data' ][ 'TagPage' ][ 0 ][ 'tag' ][ 'media' ][ 'page_info' ]
      max_id = page_info[ 'end_cursor' ]
      has_next_page = page_info[ 'has_next_page' ]

      data.each { |item|
        break if index >= max_items
        url = item[ 'thumbnail_src' ]
        image = MiniMagick::Image.open( url )
        index += 1 if crop_and_save_image( image, index, path )
      }
    end
    b.close # IMPORTANT!
  end
end

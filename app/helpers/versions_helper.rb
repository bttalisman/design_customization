
# Versions Helper
module VersionsHelper
  include CollagesHelper
  include ReplacementImagesHelper
  include ImageHelper
  include GoogleDriveHelper

  # Every version has its own folder, used for building modified AI files.
  # This folder will contain a copy of the AI file from the template,
  # configuration files, data files, everything needed to run whatever
  # AI scripts.  Calling this method will create this folder if it doesn't
  # exist.
  def get_version_folder( version )
    app_config = Rails.application.config_for( :customization )
    versions_folder = app_config[ 'path_to_versions_folder' ]
    version_output_folder = versions_folder + version.id.to_s

    Rails.logger.info 'VERSIONS_HELPER - get_version_folder() -'\
      + ' version_output_folder: '\
      + version_output_folder.to_s

    FileUtils.mkdir_p( version_output_folder )\
      unless File.directory?( version_output_folder )
    version_output_folder
  end

  # This is the local public folder into which rendered images are placed.
  def get_local_render_folder( version )
    app_config = Rails.application.config_for( :customization )
    render_root_folder = app_config[ 'path_to_local_render_folder_root' ]

    paths = get_paths( version )
    output_file_base_name = paths[ :output_file_base_name ]

    render_folder = render_root_folder + output_file_base_name + '/'
    FileUtils.mkdir_p( render_folder ) unless File.directory?( render_folder )

    Rails.logger.info 'VERSIONS_HELPER - get_local_render_folder() -'\
      + ' render_folder: ' + render_folder.to_s

    render_folder
  end

  # This is the url that specifies the set of rendered images. Formatted to
  # suit jquery reel, http://jquery.vostrel.cz/reel
  def get_render_image_url( version, plus_size )
    paths = get_paths( version )
    output_file_base_name = paths[ :output_file_base_name ]
    url = output_file_base_name + '/image.png'
    url
  end


  #
  def get_original_image_url( version )
    paths = get_paths( version )
    output_file_base_name = paths[ :output_file_base_name ]
    url = output_file_base_name + '/original.png'
    url
  end


  # This method copies the final bitmap output to the local render folder
  # root.  This is the location where client-side render engine looks for
  # bitmaps.
  def copy_output_to_local_render_folder( version )
    render_folder = get_local_render_folder( version )
    render_file = render_folder + 'image.png'

    paths = get_paths( version )
    output_folder = paths[ :output_folder ]
    output_file_base_name = paths[ :output_file_base_name ]

    png_file = output_folder + output_file_base_name + '.png'
    FileUtils.cp( png_file, render_file ) if File.exist?( png_file )
  end


  def copy_original_to_local_render_folder( version )
    render_folder = get_local_render_folder( version )

    dt_output_folder = get_design_template_folder( version.design_template )
    original_file = dt_output_folder + '/original.png'

    original_render_file = render_folder + 'original.png'
    FileUtils.cp( original_file, original_render_file ) if File.exist?( original_file )

  end





  # A version's values is a json obj describing all extensible settings,
  # set by the user.  See README.md
  def get_values_object( version )
    values_string = version.values
    values = {}
    if json?( values_string )
      values = JSON.parse values_string
    else
      Rails.logger.info 'VERSIONS_HELPER - get_values_object() - INVALID JSON!!'
    end
#    Rails.logger.info 'versions_helper - get_values_object() - values: '\
#      + JSON.pretty_generate( values )
    values
  end

  # Get the id of the ReplacementImage associated with the specified image name.
  # Should return nil if the image name doesn't exist, or it's associated with
  # something else such as a Collage.
  def get_replacement_image_id( image_name, version )
    Rails.logger.info 'VERSIONS_HELPER - get_replacement_image_id()!!'
    values = get_values_object( version )
    image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ] unless values.nil?
    rep_id = ''
    if image_values
      vals = image_values[ image_name ]
      rep_id = vals[ VERSION_VALUES_KEY_RI_ID ] if vals
    end
    rep_id
  end

  # Get the id of the Collage associated with the specified image name.
  # Should return nil if the image name doesn't exist, or it's associated with
  # something else such as a ReplacementImage.
  def get_collage_id( image_name, version )
    Rails.logger.info 'VERSIONS_HELPER - get_collage_id()!! - image_name: '\
      + image_name
    values = get_values_object( version )
    image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]\
      unless values.nil?
    col_id = ''
    if image_values
      vals = image_values[ image_name ]
      col_id = vals[ VERSION_VALUES_KEY_COLLAGE_ID ] if vals
    end
    Rails.logger.info 'VERSIONS_HELPER - get_collage_id() - col_id: '\
      + col_id.to_s
    col_id
  end

  # Returns IMAGE_TYPE_...
  def get_type( image_name, version )
    values = get_values_object( version )
    image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]\
      unless values.nil?
    type = ''
    if image_values
      vals = image_values[ image_name ]
      type = vals[ VERSION_VALUES_KEY_TYPE ] if vals
    end
    type
  end

  # If, within the specified version, the item named image_name
  # is associated with a Collage
  def associated_with_collage?( image_name, version )
    type = get_type( image_name, version )
    b = false
    b = true if type == IMAGE_TYPE_COLLAGE
    Rails.logger.info 'VERSIONS_HELPER - associated_with_collage?()'\
      + ' - image_name: ' + image_name.to_s
    Rails.logger.info 'VERSIONS_HELPER - associated_with_collage?() - b: '\
      + b.to_s
    b
  end

  # If, within the specified version, the item named image_name
  # is associated with a ReplacementImage
  def associated_with_replacement_image?( image_name, version )
    type = get_type( image_name, version )
    b = false
    b = true if type == IMAGE_TYPE_REPLACEMENT_IMAGE
    Rails.logger.info 'VERSIONS_HELPER - associated_with_replacement_image?()'\
      + ' - image_name: '\
      + image_name.to_s
    Rails.logger.info 'VERSIONS_HELPER - associated_with_replacement_image?() - b: '\
      + b.to_s
    b
  end

  def get_collage( image_name, version )
    id = get_collage_id( image_name, version )
    co = Collage.find( id ) if is_integer?( id )
    co
  rescue
    nil
  end

  def get_url( image_name, version )
    ri = get_replacement_image( image_name, version )
    url = ri.url if ri
    url
  end

  def get_replacement_image( image_name, version )
    id = get_replacement_image_id( image_name, version )
    ri = ReplacementImage.find( id ) if is_integer?( id )
    ri
  rescue
    nil
  end

  # A version associates image_names with actual uploaded files
  def get_uploaded_file( image_name, version )
    Rails.logger.info 'VERSIONS_HELPER - get_uploaded_file()'

    values = get_values_object( version )
    image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]\
      unless values.nil?

    if image_values
      vals = image_values[ image_name ]
      if vals
        rep_id = vals[ VERSION_VALUES_KEY_RI_ID ]
        ri = ReplacementImage.find( rep_id ) if rep_id
      end
    end
    ri.uploaded_file if ri
  end

  def get_uploaded_file_name( image_name, version )
    file_name = ''
    if associated_with_replacement_image?( image_name, version )
      uploaded_file = get_uploaded_file( image_name, version )
      file_name = uploaded_file.original_filename if uploaded_file
    end
    file_name
  end

  def get_local_image_path( image_name, version )
    replacement_path = ''
    if associated_with_replacement_image?( image_name, version )
      uploaded_file = get_uploaded_file( image_name, version )
      replacement_path = uploaded_file.path if uploaded_file
    end
    replacement_path
  end

  def set_tag_values( version, params )
    Rails.logger.info 'VERSIONS_HELPER - set_tag_values() - params: '\
      + params.to_s

    tag_count = params[ 'tag_count' ]
    tag_count = if tag_count != ''
                    tag_count.to_i
                  else
                    0
                  end

    all_tag_settings = {}
    tag_count.times do |i|
      tag_settings = {}
      tag_name = params[ 'tag_name' + i.to_s ]
      rep_text = params[ 'replacement_text' + i.to_s ]
      text_color = params[ 'ver_color_val' + i.to_s ]

      tag_settings[ VERSION_VALUES_KEY_REPLACEMENT_TEXT ] = rep_text
      tag_settings[ VERSION_VALUES_KEY_TEXT_COLOR ] = text_color

      all_tag_settings[ tag_name ] = tag_settings
    end

    values = get_values_object( version )
    values[ VERSION_VALUES_KEY_TAG_SETTINGS ] = all_tag_settings
    version.values = values.to_json

    Rails.logger.info 'VERSIONS_HELPER - set_tag_values() - version saved!'\
      if version.save
  end

  # This method removes any associates with a given image name, for a given
  # version.
  def clear_image_associations( image_name, version )
    # get any replacement_image or collage already associated with this
    # image_name, and destroy it.
    if associated_with_replacement_image?( image_name, version )
      ri = get_replacement_image( image_name, version )
      ri.destroy if ri
    end

    if associated_with_collage?( image_name, version )
      co = get_collage( image_name, version )
      co.destroy if co
    end

    values = get_values_object( version )
    if values
      image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]
      image_values.delete( image_name ) if image_values
      version.values = values.to_json
    end
  end

  def set_trans_butt_values( version, params )
    Rails.logger.info 'VERSIONS_HELPER - set_trans_butt_values() - params: '\
      + params.to_s

    all_trans_butt_settings = {}
    all_trans_butt_settings[ VERSION_VALUES_KEY_TB_TEXT ] = params[ 'text' ]
    all_trans_butt_settings[ VERSION_VALUES_KEY_TB_COLOR ] = params[ 'color' ]
    all_trans_butt_settings[ VERSION_VALUES_KEY_TB_HW_RATIO ] = params[ 'h_to_w' ]
    all_trans_butt_settings[ VERSION_VALUES_KEY_TB_V_ALIGN ] = params[ 'align' ]
    all_trans_butt_settings[ VERSION_VALUES_KEY_TB_FONT ] = params[ 'font' ]

    values = get_values_object( version )
    values[ VERSION_VALUES_KEY_TRANS_BUTT_SETTINGS ] = all_trans_butt_settings
    version.values = values.to_json

    Rails.logger.info 'VERSIONS_HELPER - set_trans_butt_values() - values: '\
      + JSON.pretty_generate( values )

    Rails.logger.info 'VERSIONS_HELPER - set_trans_butt_values() - version saved!'\
      if version.save

  end



  # This method updates a version's values json and associated ReplacementImages
  # and Collages.
  # params must contain an 'image_count' property.
  # params contain values keyed by:
  # => replacement_image<index>,
  # => image_name<index>,
  # => type<index>,
  # => collage_query<index>
  # for each image.
  def set_image_values( version, params )
    Rails.logger.info 'versions_helper - set_image_values() - params: '\
      + params.to_s

    design_template = version.design_template
    images = get_images_array( design_template )

    image_count = params[ 'image_count' ]
    image_count = if image_count != ''
                    image_count.to_i
                  else
                    0
                  end

    # go through all of the images.  For each, determine if its an uploaded file
    # or an instagam.
    image_count.times do |i|
      p_name = 'type' + i.to_s
      type = params[ p_name ]

      p_name = 'url' + i.to_s
      url = params[ p_name ]

      p_name = 'replacement_image' + i.to_s
      replacement_image = params[ p_name ]

      p_name = 'image_name' + i.to_s
      image_name = params[ p_name ]

      p_name = 'collage_query_string' + i.to_s
      query_string = params[ p_name ]

      p_name = 'collage_query_type' + i.to_s
      query_type = params[ p_name ]

      query = { instagram: { type: query_type, query_string: query_string } }
      query = query.to_json

      Rails.logger.info 'VERSIONS_HELPER - set_image_values() - type: '\
        + type.to_s
      Rails.logger.info 'VERSIONS_HELPER - set_image_values() - image_name: '\
        + image_name.to_s
      Rails.logger.info 'VERSIONS_HELPER - set_image_values() - replacement_image: '\
        + replacement_image.to_s
      Rails.logger.info 'VERSIONS_HELPER - set_image_values() - query: '\
        + query.to_s


      if type == 'upload'
        if replacement_image
          my_file = replacement_image[ 'uploaded_file' ]
          Rails.logger.info 'VERSIONS_HELPER - set_image_values() - my_file: '\
            + my_file.to_s

          if my_file
            clear_image_associations( image_name, version )
            replacement_image = version.replacement_images.create( { uploaded_file: my_file,
                                                                     image_name: image_name } )
#            replacement_image.image_name = image_name
            replacement_image.save

            # this will set version.values to reflect any user-set properties
            # for this version, these values will eventually be read by
            # the AI script
            add_replacement_image_to_version( replacement_image,\
                                              image_name, version )
          end # my_file
        end # we have a replacement_image
      elsif( type == 'web' )
        Rails.logger.info 'VERSIONS_HELPER - set_image_values() - WEB URL!'
        Rails.logger.info 'VERSIONS_HELPER - set_image_values() - url: ' + url.to_s

        clear_image_associations( image_name, version )
        replacement_image = version.replacement_images.create( { image_name: image_name,
                                                                 url: url } )
        replacement_image.save

        fetch_image( replacement_image )

        # this will set version.values to reflect any user-set properties
        # for this version, these values will eventually be read by
        # the AI script
        add_replacement_image_to_version( replacement_image,\
                                          image_name, version )


      else
        # type = instagram collage
        Rails.logger.info 'VERSIONS_HELPER - set_image_values() - Instagram collage!'
        c = get_collage( image_name, version )

        if( c.nil? || c.query != query )
          # Either there was no associated collage, or the query has changed.
          Rails.logger.info 'VERSIONS_HELPER - set_image_values() - Building a new Collage.'
          o = { query: query }
          clear_image_associations( image_name, version )
          collage = version.collages.create( o )
          collage.image_name = image_name
          collage.save
          build_collage_folder( collage )
          add_collage_to_version( collage, image_name, version )
        else
          Rails.logger.info 'VERSIONS_HELPER - set_image_values() - Keeping the old Collage'
        end
      end
    end # image_count times
  end


  # For images and tags, the existance of tags and named images indicates that
  # a replacement should occur.  All designs have colors, so the existance of
  # colors isnt sufficient.  This method determines if colors are being replaced.
  def replace_colors?( version )
    b = false
    values = get_values_object( version )
    if( values )
      color_vals = values[ VERSION_VALUES_KEY_COLOR_SETTINGS ]
      if( color_vals )
        if( color_vals.length > 0 )
          b = true
        end
      end
    end
    b
  end


  def set_color_values( version, params )
    Rails.logger.info 'versions_helper - set_color_values() - params: '\
      + params.to_s

    design_template = version.design_template
    colors = get_colors_array( design_template )

    all_color_settings = {}

    color_count = params[ 'color_count' ]
    color_count = if color_count != ''
                    color_count.to_i
                  else
                    0
                  end

    Rails.logger.info 'VERSIONS_HELPER - set_color_values() - color_count: '\
      + color_count.to_s

    # go through all of the colors.
    color_count.times do |i|

      color_settings = {}

      p_name = 'color_name' + i.to_s
      color_name = params[ p_name ]

      p_name = 'color_val' + i.to_s
      color_val = params[ p_name ]

      p_name = 'selected_c_val' + i.to_s
      c = params[ p_name ]

      p_name = 'selected_m_val' + i.to_s
      m = params[ p_name ]

      p_name = 'selected_y_val' + i.to_s
      y = params[ p_name ]

      p_name = 'selected_k_val' + i.to_s
      k = params[ p_name ]

      p_name = 'original_c_val' + i.to_s
      orig_c = params[ p_name ]

      p_name = 'original_m_val' + i.to_s
      orig_m = params[ p_name ]

      p_name = 'original_y_val' + i.to_s
      orig_y = params[ p_name ]

      p_name = 'original_k_val' + i.to_s
      orig_k = params[ p_name ]


      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_C ] = c
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_M ] = m
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_Y ] = y
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_K ] = k
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_HEX ] = color_val

      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_C ] = orig_c
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_M ] = orig_m
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_Y ] = orig_y
      color_settings[ VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_K ] = orig_k

      all_color_settings[ color_name ] = color_settings

      Rails.logger.info 'VERSIONS_HELPER - set_color_values() - color_settings: '\
        + JSON.pretty_generate( color_settings )

    end # color_count times

    values = get_values_object( version )
    values[ VERSION_VALUES_KEY_COLOR_SETTINGS ] = all_color_settings
    version.values = values.to_json

    Rails.logger.info 'VERSIONS_HELPER - set_color_values() - NEW VALUES: '\
      + JSON.pretty_generate( values )
    Rails.logger.info 'VERSIONS_HELPER - set_color_values() - version saved!'\
      if version.save
  end


  # a version's values object matches image tags to replacement_images.
  # this method gets that version's values, and updates it with the id of
  # the replacement_image, as well as the path to the local file,
  # as this is needed by the AI script.
  def add_replacement_image_to_version( ri, image_name, version )
    Rails.logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'
    Rails.logger.info 'VERSIONS_HELPER - add_replacement_image_to_version() - ri: '\
      + ri.to_s

    values = get_values_object( version )
    image_settings = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]

    settings = {}
    settings[ VERSION_VALUES_KEY_RI_ID ] = ri.id
    settings[ VERSION_VALUES_KEY_PATH ] = ri.get_path
    settings[ VERSION_VALUES_KEY_TYPE ] = IMAGE_TYPE_REPLACEMENT_IMAGE
    image_settings[ image_name ] = settings

    Rails.logger.info 'VERSIONS_HELPER - add_replacement_image_to_version() - values: '\
      + JSON.pretty_generate( values )

    version.values = values.to_json
    version.save
  end

  # a version's values object matches image tags to collages.
  # this method gets that version's values, and updates it with the id of
  # the collage, as well as the path to the local folder where a collage's
  # images are stored, as this is needed by the AI script.
  def add_collage_to_version( co, image_name, version )
    Rails.logger.info 'VERSIONS_HELPER - add_collage_to_version()'
    Rails.logger.info 'VERSIONS_HELPER - add_collage_to_version() - co: '\
      + co.to_s

    values = get_values_object( version )
    image_settings = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]

    settings = {}
    settings[ VERSION_VALUES_KEY_COLLAGE_ID ] = co.id
    settings[ VERSION_VALUES_KEY_PATH ] = co.path
    settings[ VERSION_VALUES_KEY_TYPE ] = IMAGE_TYPE_COLLAGE

    image_settings[ image_name ] = settings
    version.values = values.to_json
    version.save
  end

  # This method writes the current version's values string to a file sitting
  # right next to an AI file, named with _data.jsn.
  def write_temp_data_file( version, path_to_ai_file )
    temp_values_file = path_to_data_file( path_to_ai_file )

    Rails.logger.info 'versions_helper - write_temp_data_file()'\
      + ' - temp_values_file: ' + temp_values_file.to_s
    Rails.logger.info 'versions_helper - write_temp_data_file()'\
      + ' - version.values.to_s: ' + version.values.to_s

    # we'll create a temporary file containing necessary info, sitting right
    # next to the original ai file.
    File.open( temp_values_file, 'w' ) do |f|
      f.write( version.values.to_s )
    end
  end

  def remove_data_file( path_to_ai_file )
    Rails.logger.info 'versions_helper - remove_data_file() !!!!!!!!!!!'
    temp_values_file = path_to_data_file( path_to_ai_file )
    File.delete( temp_values_file )
  end

  # This method returns the path to the configuration file for a version,
  # to be used as an argument to the run_AI_script script.  If the options
  # parameter contains version_id, that version will be used, otherwise
  # the version session variable will be used.
  def config_file_name( options = {} )
    version_id = options[ 'version_id' ]
    version = options[ 'version' ]

    v = if version_id.nil?
          version
        else
          Version.find( version_id )
        end

    Rails.logger.info 'versions_helper - config_file_name() - v: '\
      + v.to_s

    version_output_folder = get_version_folder( v )
    config_file = version_output_folder + '/config_ai.jsn'
    config_file
  end

  def process_version_system_call( version )
    app_config = Rails.application.config_for( :customization )
    path = app_config[ 'path_to_runner_script' ]
    sys_com = 'ruby ' + path + ' "'\
      + config_file_name( 'version' => version ) + '"'
    Rails.logger.info 'versions_helper - system_call() - about to run '\
      + 'sys_com: ' + sys_com.to_s

    system( sys_com )
  end

  def process_version_send_remote( version )
    Rails.logger.info 'versions_helper - process_version_send_remote()'
    uri_string = remote_host + '/do_process_version?version_id='\
      + version.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'versions_helper - process_version_send_remote()'\
        + ' - response.code: '\
        + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def maybe_bail_out( version, tags, images, params )
    runai = params[ 'runai' ]

    # bail out for any of these reasons
    raise BailOutOfProcessing, 'Zombie DesignTemplate.'\
      if version.design_template.original_file == 'nil'
    raise BailOutOfProcessing, 'No DesignTemplate.'\
      if version.design_template.nil?
    raise BailOutOfProcessing, 'Run AI checkbox unchecked.'\
      if runai != 'true'
    raise BailOutOfProcessing, 'No extracted images or tags.'\
      if images.empty? && tags.empty? && !replace_colors?( version )
  end

  def prepare_files( version, config )
    # this will put an appropriately named data file right next to the
    # source file.  The data file will contain the version.values data.
    write_temp_data_file( version, config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] )

    # this will put a configuration json file in the version folder.  this file
    # tells bin/run_AI_script necessary file locations
    File.open( config_file_name( 'version' => version ), 'w' ) do |f|
      f.write( config.to_json )
    end
  end

  def prep_and_run( version, config )
    Rails.logger.info( 'versions_helper - prep_and_run() - config: '\
      + JSON.pretty_generate( config ) )

    prepare_files( version, config )

    # custom configuration found in config/customization.yml
    app_config = Rails.application.config_for( :customization )
    run_remotely = app_config[ 'run_remotely' ]

    if !run_remotely
      # run locally
      process_version_system_call( version )
    else
      # send remote HTTP request
      process_version_send_remote( version )
    end

    remove_data_file( config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] )
  end


  def get_output_folder( version )
    if version.output_folder_path != '' && !version.output_folder_path.nil?
      # the user has specified an output folder
      output_folder = guarantee_final_slash( version.output_folder_path )
    else
      # the user has not specified an output folder,
      # we'll just use the version folder
      output_folder = guarantee_final_slash( version_folder )
    end
    output_folder
  end


  def send_to_render( version, params )
    do_render = to_boolean( params[ 'render' ] )
    Rails.logger.info 'VERSION_HELPER - send_to_render() - do_render: '\
      + do_render.to_s

    if do_render
      paths = get_paths( version )
      output_folder = paths[ :output_folder ]
      original_file_path = paths[ :original_file_path ]
      original_file_base_name = paths[ :original_file_base_name ]
      output_file_base_name = paths[ :output_file_base_name ]

      png_file = output_folder + output_file_base_name + '.png'

      command = %Q[ gdrive upload -p 0B0Pbgd52b3LYU3pheTJVVzZvVW8 '#{png_file}' ]

      Rails.logger.info 'VERSION_HELPER - send_to_render() - command: ' + command.to_s
      system( command )

      version.last_render_date = DateTime.now
      version.save
    end # if do_render
  end

  def get_paths( version )
    #file_name = version.name # TODO should not be based on version name?
    file_name = version.design_template.id.to_s + '_' + version.id.to_s

    original_file = version.design_template.original_file
    original_file_path = original_file.path
    original_file_name = File.basename( original_file_path )
    original_file_base_name = File.basename( original_file_path, '.ai' )
    version_folder = get_version_folder( version )
    version_file_path = version_folder + '/' + original_file_name
    output_folder = get_output_folder( version )
    output_file_base_name = make_suitable_file_name( file_name.to_s ) + '_final'
    intermediate_output = output_folder.to_s + output_file_base_name + '.ai'

    o = {
      original_file_path: original_file_path,
      original_file_name: original_file_name,
      original_file_base_name: original_file_base_name,
      version_folder: version_folder,
      version_file_path: version_file_path,
      output_folder: output_folder,
      output_file_base_name: output_file_base_name,
      intermediate_output: intermediate_output
    }

    #Rails.logger.info 'versions_helper - get_paths() - o: '\
    #  + JSON.pretty_generate( o )
    o
  end


  # This method does everything necessary to generate modified AI files and
  # AI output specified by a particular version.
  # The original AI file is copied from the associated DesignTemplate into
  # the version folder. This folder is unique to
  # the version, and where all originals are located and output is placed
  # before being moved to the output folder.
  # version.values json is written to the version folder.  This contains all
  # user-specified data.
  # A config file containing necessary paths, used by
  # bin/illustrator_processing/run_AI_script, is created.
  # If processing is local, system_call() runs ruby.
  # If processing is remote, send_remote_run_request() sends an HTTP request
  # containing the version id
  def process_version( version, params )
    Rails.logger.info 'VERSION_HELPER - process_version()'

    design_template = version.design_template
    # this is an array of tag names, extracted from the AI file
    tags = get_tags_array( design_template )
    # this is an array of image names, extracted from the AI file
    images = get_images_array( design_template )

    replace_colors = replace_colors?( version )

    maybe_bail_out( version, tags, images, params )

    # Generate trans-butt images
    process_trans_butt_images( version )

    paths = get_paths( version )

    original_file_path = paths[ :original_file_path ]
    original_file_name = paths[ :original_file_name ]
    original_file_base_name = paths[ :original_file_base_name ]
    version_folder = paths[ :version_folder ]
    version_file_path = paths[ :version_file_path ]
    output_folder = paths[ :output_folder ]
    output_file_base_name = paths[ :output_file_base_name ]
    intermediate_output = paths[ :intermediate_output ]

    # copy the original file to the version folder, same name
    FileUtils.cp( original_file_path, version_file_path )

    int_file_exist = false
    app_config = Rails.application.config_for( :customization )

    if !tags.empty?
      # There are tags to replace, we should replace tags
      script_path = app_config[ 'path_to_search_replace_script' ]

      config = {}
      config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = version_file_path
      config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = script_path
      config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
      config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = output_file_base_name

      prep_and_run( version, config )

      # unless something went wrong, this should exist
      int_file_exist = File.exist?( intermediate_output )

    end # there are tags to replace

    if !images.empty?
      # There are images to replace, we should replace images
      Rails.logger.info( 'versions_helper - process_version() - about to replace images' )
      config = {}
      if int_file_exist
        config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = intermediate_output
      else
        # the intermediate file does not exist, but we should still
        # replace images
        config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = version_file_path
      end

      config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_image_search_replace_script' ]
      config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
      config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = output_file_base_name

      prep_and_run( version, config )

      # unless something went wrong, this should exist
      int_file_exist = File.exist?( intermediate_output )

    end # there are images to replace

    if replace_colors
      # There are colors to replace, we should replace images
      Rails.logger.info( 'versions_helper - process_version() - about to replace colors' )
      config = {}
      if int_file_exist
        config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = intermediate_output
      else
        # the intermediate file does not exist, but we should still
        # replace images
        config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = version_file_path
      end

      config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_color_search_replace_script' ]
      config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
      config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = output_file_base_name

      prep_and_run( version, config )

    end # there are colors to replace


  rescue => e
    Rails.logger.info 'versions_helper - Bailing Out! - ' + e.inspect
    Rails.logger.info JSON.pretty_generate( JSON.parse( e.backtrace.to_s ) )
  end


  def process_trans_butt_images( version )
    return if !version.design_template.is_trans_butt

    Rails.logger.info 'version_helper - process_trans_butt_images()'

    app_config = Rails.application.config_for( :customization )
    text_processing_folder = app_config[ 'path_to_text_processing_folder' ]
    script_path = app_config[ 'path_to_split_text_script' ]
    path_to_doc = text_processing_folder + 'text_processing.ai'
    path_to_config = text_processing_folder + 'config.json'
    path_to_data = text_processing_folder + 'text_data.jsn'
    output_folder = text_processing_folder + 'output/'

    Rails.logger.info 'version_helper - process_trans_butt_images() - text_processing_folder: ' + text_processing_folder.to_s

    FileUtils.mkdir_p( text_processing_folder )\
      unless File.directory?( text_processing_folder )

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = path_to_doc
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = script_path
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
    config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = ''

    File.open( path_to_config, 'w' ) do |f|
      f.write( config.to_json )
    end

    values = get_values_object( version )
    trans_butt_values = values[ VERSION_VALUES_KEY_TRANS_BUTT_SETTINGS ]
    return if trans_butt_values.nil?

    Rails.logger.info 'version_helper - process_trans_butt_images() - trans_butt_values: '\
      + trans_butt_values.to_s
    Rails.logger.info 'version_helper - process_trans_butt_images() - path_to_data: '\
      + path_to_data.to_s

    data = {}
    data[ 'text' ] = trans_butt_values[ VERSION_VALUES_KEY_TB_TEXT ]
    data[ 'heightToWidthRatio' ] = trans_butt_values[ VERSION_VALUES_KEY_TB_HW_RATIO ]
    data[ 'color' ] = trans_butt_values[ VERSION_VALUES_KEY_TB_COLOR ]
    data[ 'width' ] = 1000
    data[ 'align' ] = trans_butt_values[ VERSION_VALUES_KEY_TB_V_ALIGN ]
    data[ 'font' ] = trans_butt_values[ VERSION_VALUES_KEY_TB_FONT ]

    File.open( path_to_data, 'w' ) do |f|
      f.write( data.to_json )
    end

    runner_path = app_config[ 'path_to_runner_script' ]
    sys_com = 'ruby ' + runner_path + ' "' + path_to_config + '"'
    Rails.logger.info 'version_helper - process_trans_butt_images() - about to run '\
      + 'sys_com: ' + sys_com.to_s
    system( sys_com )


    ri_path = output_folder + 'left.png'
    file = File.new( ri_path )
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save

    image_name = get_left_butt_image_name( version.design_template )
    add_replacement_image_to_version( ri, image_name, version )


    ri_path = output_folder + 'right.png'
    file = File.new( ri_path )
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save

    image_name = get_right_butt_image_name( version.design_template )
    add_replacement_image_to_version( ri, image_name, version )

  end


  # This method iterates through all of the replacement_images associated
  # with a version, and performs any processing necessary. ZIP files are
  # unziped, image files are scaled and cropped
  def process_replacement_images( version )
    Rails.logger.info 'versions_helper - process_replacement_images()'
    design_template = version.design_template

    version.replacement_images.each { |ri|
      type = ri.uploaded_file_content_type
      image_name = ri.image_name

      Rails.logger.info 'versions_helper - process_replacement_images() - type!!: '\
        + type.to_s
      Rails.logger.info 'versions_helper - process_replacement_images() - image_name: '\
        + image_name.to_s

      if image_name
        if type == 'application/zip'
          ri.unzip
          resize_images_from_zip( design_template, ri )
        elsif type == 'image/jpeg'
          path = ri.get_path.to_s
          resize_image_from_image_file( design_template, ri, path )
        elsif type == 'image/png'
          Rails.logger.info 'versions_helper - process_replacement_images() - png '
          path = ri.get_path.to_s
          resize_image_from_image_file( design_template, ri, path )
        end
      end # if image_name

    }
  end

end

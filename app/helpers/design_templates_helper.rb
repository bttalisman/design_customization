# DesignTemplates Helper
module DesignTemplatesHelper

  include ColorsHelper

  # the path to the tags file is based on the path to the original ai file.
  def path_to_tags_file( design_template )
    file = design_template.original_file

    # todo - do this better
    if !file.path.nil?
      source_path = file.path.to_s
      source_folder = File.dirname( source_path )
      data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
        + '_tags.jsn'
    else
      # zombie!
      Rails.logger.info 'DesignTemplatesHelper - path_to_tags_file() - zombie!'
      dt_folder = get_design_template_folder( design_template )
      data_file = dt_folder + 'zombie_tags.jsn'
    end
    data_file
  end

  # the path to the images file is based on the path to the original ai file.
  def path_to_images_file( design_template )
    file = design_template.original_file

    if !file.path.nil?
      source_path = file.path.to_s
      source_folder = File.dirname( source_path )
      data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
        + '_images.jsn'
    else
      # zombie!
      Rails.logger.info 'DesignTemplatesHelper - path_to_images_file() - zombie!'
      dt_folder = get_design_template_folder( design_template )
      data_file = dt_folder + 'zombie_images.jsn'
    end

    data_file
  end

  # the path to the colors file is based on the path to the original ai file.
  def path_to_colors_file( design_template )
    file = design_template.original_file

    if !file.path.nil?
      source_path = file.path.to_s
      source_folder = File.dirname( source_path )
      data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
        + '_all_colors.jsn'
    else
      # zombie!
      dt_folder = get_design_template_folder( design_template )
      data_file = dt_folder + 'zombie_colors.jsn'
    end

    Rails.logger.info 'DesignTemplatesHelper - path_to_colors_file() - data_file: '\
      + data_file.to_s
    data_file
  end

  def colors_file_exist?( design_template )
    path = path_to_colors_file( design_template )
    exists = File.exist?( path )
    exists
  end

  def tags_file_exist?( design_template )
    path = path_to_tags_file( design_template )
    exists = File.exist?( path )
    exists
  end

  # Given a template, this method returns an object providing metadata on that
  # template.
  #
  # returns - { 'valid' => true/false,
  #             'message' => helpful text for users,
  #             'status' => see config/initializers/constants.rb }
  def get_stats( dt )
    valid = true
    status = TEMPLATE_STATUS_SUCCESS

    # No tags and no images
    if !tags?( dt ) && !images?( dt ) && !colors?( dt )
      Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_stats() - No tags or images or colors.'
      valid = false
      message = 'This file contains no tags, images, or colors for replacement.'
      status = TEMPLATE_STATUS_NOT_A_TEMPLATE
    end

    # Duplicate tags
    tags = get_tags_array( dt )
    if tags.uniq.length != tags.length
      Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_stats() - duplicate tags.'
      valid = false
      message = 'This file contains duplicate tags, please make all tags unique.'
      status = TEMPLATE_STATUS_DUP_TAGS
    end

    o = { DESIGN_TEMPLATE_STATS_KEY_VALID => valid,
          DESIGN_TEMPLATE_STATS_KEY_MESSAGE => message,
          DESIGN_TEMPLATE_STATS_KEY_STATUS => status }
    o
  end

  # This method returns an array of extracted tags.  These are the strings
  # of text within an AI file that will be replaced by versions of this
  # template.
  def get_tags_array( design_template )
    tags_file = path_to_tags_file( design_template )
    tags = load_array_file( tags_file )
    tags
  end

  # This method returns an array of extracted colors.
  #
  # [ { c: '233', m: '222', y: '111', k: '122' } ]
  #
  def get_colors_array( design_template )
    colors_file = path_to_colors_file( design_template )
    colors = load_array_file( colors_file )
    colors
  end

  # Returns true if this template is built from an AI file containing tags.
  # More specifically, true if the tags file found in this version's folder
  # represents a valid, non-empty json array of tag names.
  def tags?( design_template )
    a = get_tags_array( design_template )
    return false if a.empty?
    true
  end

  # Returns true if this template is built from an AI file containing images.
  # More specifically, true if the images file found in this version's folder
  # represents a valid, non-empty json array of image names.
  def images?( design_template )
    a = get_images_array( design_template )
    return false if a.empty?
    true
  end

  # Returns true if this template is built from an AI file containing colors.
  # TODO is this useful?
  def colors?( design_template )
    a = get_colors_array( design_template )
    return false if a.empty?
    true
  end


  # This method returns an array of extracted image data.  These are the
  # placed items within an AI file that will be replaced by versions of this
  # template.
  # [
  #    { name: 'bob', height: '34', width: '355' }
  # ]
  def get_images_array( design_template )
    images_file = path_to_images_file( design_template )
    images = load_array_file( images_file )
    images
  end

  # This method returns an array of image names.  These are the names of
  # placed items within the original AI file.
  def get_image_names_array( design_template )
    images = get_images_array( design_template )
    names = []
    images.each { |i|
      names << i[ 'name' ]
    }
    names
  end

  # This method gets the object literal describing the placed item with the
  # specified image_name.  This is pulled from the json file describing placed
  # items, located at path_to_images_file()
  def get_image_object( design_template, image_name )
    extracted_image_data = get_images_array( design_template )
    found_obj = {}
    extracted_image_data.each { |i|
      if( i[ 'name' ] == image_name )
        found_obj = i
        break
      end
    }
    found_obj
  end

  # This method returns the image_name that references the placed item which
  # is the left-butt image.
  def get_left_butt_image_name( design_template )
    prompts = get_prompts_object( design_template )
    tb_settings = prompts[ PROMPTS_KEY_TRANS_BUTT_SETTINGS ]
    if( !tb_settings.nil? )
      image_name = tb_settings[ PROMPTS_KEY_TRANS_BUTT_LEFT_IMAGE_NAME ]
    end
    image_name
  end

  # This method returns the image_name that references the placed item which
  # is the right-butt image.
  def get_right_butt_image_name( design_template )
    prompts = get_prompts_object( design_template )
    tb_settings = prompts[ PROMPTS_KEY_TRANS_BUTT_SETTINGS ]
    if( !tb_settings.nil? )
      image_name = tb_settings[ PROMPTS_KEY_TRANS_BUTT_RIGHT_IMAGE_NAME ]
    end
    image_name
  end

  # This method returns true if the placed item referenced by image_name is
  # either the left-butt image or the right-butt image.
  def is_trans_butt_image( design_template, image_name )
    prompts = get_prompts_object( design_template )

    b = false
    tb_settings = prompts[ PROMPTS_KEY_TRANS_BUTT_SETTINGS ]
    if( !tb_settings.nil? )
      left = tb_settings[ PROMPTS_KEY_TRANS_BUTT_LEFT_IMAGE_NAME ]
      right = tb_settings[ PROMPTS_KEY_TRANS_BUTT_RIGHT_IMAGE_NAME ]
      if( (left == image_name) || (right == image_name) )
        b = true
      end
    end
    b
  end

  # This method returns the width of the original image that is a placed item
  # in the AI file.  This is the width in pixels of the image before any transformations
  # have been made.  Replacement images may be scaled and cropped to match this
  # size. In this case, after transformations are made to the replacement image,
  # the result should be the same size and shape as the placed item in the
  # template file.
  def get_original_width( design_template, image_name )
    o = get_image_object( design_template, image_name )
    o[ 'width' ]
  end

  # Same here.
  def get_original_height( design_template, image_name )
    o = get_image_object( design_template, image_name )
    o[ 'height' ]
  end


  # This method constructs a new json string for the prompts field.  This
  # method must be coordinated with parameters as set in
  # views/partials/_design_template_tags.html.erb.
  def set_tag_prompts( template, params )
#    Rails.logger.info 'design_templates_helper - set_tag_prompts() - params: '\
#      + params.to_s

    tag_count = params[ 'tag_count' ]
    tag_count = if tag_count != ''
                    tag_count.to_i
                  else
                    0
                  end

    all_tag_settings = {}
    tag_count.times do |i|
      tag_settings = {}

      p_name = 'tag_name' + i.to_s
      tag_name = params[ p_name ]

      p_name = 'prompt' + i.to_s
      tag_settings[ PROMPTS_KEY_PROMPT ] = params[ p_name ]

      p_name = 'maxl' + i.to_s
      tag_settings[ PROMPTS_KEY_MAX_L ] = params[ p_name ]

      p_name = 'minl' + i.to_s
      tag_settings[ PROMPTS_KEY_MIN_L ] = params[ p_name ]

      p_name = 'colorp' + i.to_s
      if params[ p_name ]
        tag_settings[ PROMPTS_KEY_PICK_COLOR ] = PROMPTS_VALUE_TRUE
      else
        tag_settings[ PROMPTS_KEY_PICK_COLOR ] = PROMPTS_VALUE_FALSE
      end

      p_name = 'use_pal' + i.to_s
      if params[ p_name ]
        tag_settings[ PROMPTS_KEY_USE_PALETTE ] = PROMPTS_VALUE_TRUE
      else
        tag_settings[ PROMPTS_KEY_USE_PALETTE ] = PROMPTS_VALUE_FALSE
      end

      p_name = 'select_pal' + i.to_s
      tag_settings[ PROMPTS_KEY_PALETTE_ID ] = params[ p_name ]

      all_tag_settings[ tag_name ] = tag_settings
    end

    prompts_string = template.prompts
    prompts = JSON.parse( prompts_string )
    prompts[ PROMPTS_KEY_TAG_SETTINGS ] = all_tag_settings
    prompts_string = prompts.to_json
    template.prompts = prompts_string
  end

  # This method constructs a new json string for the prompts field.  This
  # method must be coordinated with parameters as set in
  # views/partials/_design_template_trans_butt.html.erb.
  # See README.md for the format of the prompts json.
  def set_trans_butt_prompts( template, params )
#    Rails.logger.info 'design_templates_helper - set_image_prompts() - params: '\
#      + params.to_s

    left_image_name = params[ 'left-butt' ]
    right_image_name = params[ 'right-butt' ]
    set_color = params[ 'trans-butt-set-color' ]

    all_trans_butt_settings = {}
    all_trans_butt_settings[ PROMPTS_KEY_TRANS_BUTT_LEFT_IMAGE_NAME ] = left_image_name
    all_trans_butt_settings[ PROMPTS_KEY_TRANS_BUTT_RIGHT_IMAGE_NAME ] = right_image_name

    if( set_color )
      all_trans_butt_settings[ PROMPTS_KEY_TRANS_BUTT_SET_COLOR ] = PROMPTS_VALUE_TRUE
    else
      all_trans_butt_settings[ PROMPTS_KEY_TRANS_BUTT_SET_COLOR ] = PROMPTS_VALUE_FALSE
    end

    prompts_string = template.prompts
    prompts = JSON.parse( prompts_string )
    prompts[ PROMPTS_KEY_TRANS_BUTT_SETTINGS ] = all_trans_butt_settings
    prompts_string = prompts.to_json
    template.prompts = prompts_string
  end


  # This method constructs a new json string for the prompts field.  This
  # method must be coordinated with parameters as set in
  # views/partials/_design_template_images.html.erb
  def set_image_prompts( template, params )
#    Rails.logger.info 'design_templates_helper - set_image_prompts() - params: '\
#      + params.to_s
    image_count = params[ 'image_count' ]
    image_count = if image_count != ''
                    image_count.to_i
                  else
                    0
                  end

    all_image_settings = {}

    image_count.times do |i|
      image_settings = {}

      p_name = 'image_name' + i.to_s
      image_name = params[ p_name ]
      p_name = 'replace_image' + i.to_s
      replace = params[ p_name ]
      p_name = 'fit_image' + i.to_s
      fit = params[ p_name ]

      height = get_original_height( template, image_name )
      width = get_original_width( template, image_name )

      if replace
        image_settings[ PROMPTS_KEY_REPLACE_IMG ] = PROMPTS_VALUE_REPLACE_IMG_TRUE
      else
        image_settings[ PROMPTS_KEY_REPLACE_IMG ] = PROMPTS_VALUE_REPLACE_IMG_FALSE
      end

      if fit
        image_settings[ PROMPTS_KEY_FIT_IMG ] = PROMPTS_VALUE_FIT_IMG_TRUE
      else
        image_settings[ PROMPTS_KEY_FIT_IMG ] = PROMPTS_VALUE_FIT_IMG_FALSE
      end

      orig_image = {}
      orig_image[ PROMPTS_KEY_ORIGINAL_HEIGHT ] = height
      orig_image[ PROMPTS_KEY_ORIGINAL_WIDTH ] = width
      image_settings[ PROMPTS_KEY_ORIGINAL_IMAGE ] = orig_image

      all_image_settings[ image_name ] = image_settings
    end

    prompts_string = template.prompts
    prompts = JSON.parse( prompts_string )
    prompts[ PROMPTS_KEY_IMAGE_SETTINGS ] = all_image_settings
    prompts_string = prompts.to_json
    template.prompts = prompts_string
  end



  # This method constructs a new json string for the prompts field.  This
  # method must be coordinated with parameters as set in
  # views/partials/_design_template_colors.html.erb
  def set_color_prompts( template, params )
    Rails.logger.info 'design_templates_helper - set_color_prompts() - params: '\
      + params.to_s
    color_count = params[ 'color_count' ]
    color_count = if color_count != ''
                    color_count.to_i
                  else
                    0
                  end

    all_color_settings = {}

    color_count.times do |i|
      color_settings = {}

      p_name = 'color_name' + i.to_s
      color_name = params[ p_name ]
      p_name = 'replace_color' + i.to_s
      replace = params[ p_name ]
      p_name = 'orig_color_hex' + i.to_s
      orig_color_hex = params[ p_name ]

      p_name = 'orig_color_c' + i.to_s
      orig_color_c = params[ p_name ]
      p_name = 'orig_color_m' + i.to_s
      orig_color_m = params[ p_name ]
      p_name = 'orig_color_y' + i.to_s
      orig_color_y = params[ p_name ]
      p_name = 'orig_color_k' + i.to_s
      orig_color_k = params[ p_name ]

      if replace
        color_settings[ PROMPTS_KEY_REPLACE_COLOR ] = PROMPTS_VALUE_TRUE
      else
        color_settings[ PROMPTS_KEY_REPLACE_COLOR ] = PROMPTS_VALUE_FALSE
      end

      color_settings[ PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_HEX ] = orig_color_hex
      color_settings[ PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_C ] = orig_color_c
      color_settings[ PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_M ] = orig_color_m
      color_settings[ PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_Y ] = orig_color_y
      color_settings[ PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_K ] = orig_color_k

      all_color_settings[ color_name ] = color_settings
    end # color_count times

    prompts_string = template.prompts
    prompts = JSON.parse( prompts_string )
    prompts[ PROMPTS_KEY_COLOR_SETTINGS ] = all_color_settings
    prompts_string = prompts.to_json
    template.prompts = prompts_string
  end

  def get_hex_string_for_color( color )
    return if color.nil?
    Rails.logger.info 'design_templates_helper - get_hex_string_for_color() - color: '\
      + JSON.pretty_generate( color )

    red_int = color['r'].to_s.to_i
    green_int = color['g'].to_s.to_i
    blue_int = color['b'].to_s.to_i

    Rails.logger.info 'design_templates_helper - get_hex_string_for_color() - r, g, b: '\
      + red_int.to_s + ', ' + green_int.to_s + ', ' + blue_int.to_s

    red_hex = red_int.to_s(16).rjust(2, '0')
    green_hex = green_int.to_s(16).rjust(2, '0')
    blue_hex = blue_int.to_s(16).rjust(2, '0')
    s = '#' + red_hex + green_hex + blue_hex
    Rails.logger.info 'design_templates_helper - get_hex_string_for_color() - s: ' + s.to_s
    s
  end

  def get_prompts_key_for_color( color )
    return if color.nil?
#    Rails.logger.info 'design_templates_helper - get_prompts_key_for_color() - color: '\
#      + JSON.pretty_generate( color )
    key = color['c'].to_s + color['m'].to_s + color['y'].to_s + color['k'].to_s
    key.to_s
  end


  # A design_template's prompts describes any extensible settings
  # presented by versions of this template, such as replace this image?, allow
  # users to set the color of this text?
  def get_prompts_object( design_template )
    prompts_string = design_template.prompts
#    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_prompts_object() - '\
#      + 'prompts_string: ' + prompts_string.to_s
    if json?( prompts_string )
      prompts = JSON.parse( prompts_string )
      Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_prompts_object() - '\
        + 'prompts: ' + JSON.pretty_generate( prompts )
    end
    prompts
  end

  def get_asset_prefs_object( design_template )
    ap_string = design_template.asset_prefs

    # if the asset prefs weren't set, save the template and try again.  Saving
    # sets the default value.
    if ap_string.nil?
      design_template.save
      ap_string = design_template.asset_prefs
    end

    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_asset_prefs_object() - '\
      + 'ap_string: ' + ap_string.to_s
    if json?( ap_string )
      prefs = JSON.parse( ap_string )
      Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_asset_prefs_object() - '\
        + 'prefs: ' + JSON.pretty_generate( prefs )
    end
    prefs
  end



  # This method makes a folder to temporarily hold output.  The folder is
  # called 'output' and it's located in the design template folder.
  def make_output_folder( design_template )
    # the illustrator scripts place all output
    # in a subfolder of the folder containing the original file, and later
    # moved to wherever
    source_folder = get_design_template_folder( design_template )
    ai_output_folder = source_folder + '/output'
    FileUtils.mkdir_p( ai_output_folder )\
        unless File.directory?( ai_output_folder )
  end

  # This method returns the path to the specified DesignTemplate's working
  # folder.
  def get_design_template_folder( design_template )
    Rails.logger.info 'design_templates_helper - get_design_template_folder()'
    app_config = Rails.application.config_for(:customization)

    file = design_template.original_file
    if !file.path.nil?
      source_path = file.path
      source_folder = File.dirname( source_path )
    else
      # zombie template!!
      Rails.logger.info 'design_templates_helper - get_design_template_folder()'\
        + ' - zombie!'
      id = design_template.id
      source_folder = app_config[ 'path_to_zombie_templates_root' ]\
        + id.to_s + '/'
    end
    source_folder
  end

  # This method returns the path to the configuration file for post-processing
  # the AI file.
  # This path is to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def post_process_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - post_process_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - post_process_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/' + RUNNER_POST_PROCESS_CONFIG_FILE_NAME
    config_file
  end

  # This method returns the path to the configuration file for extracting tags,
  # to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def tags_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - tags_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - tags_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/' + RUNNER_TAGS_CONFIG_FILE_NAME
    config_file
  end


  # This method returns the path to the configuration file for extracting images,
  # to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def images_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - images_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - images_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/' + RUNNER_IMAGES_CONFIG_FILE_NAME
    config_file
  end


  # This method returns the path to the configuration file for extracting images,
  # to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def colors_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - colors_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - colors_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/' + RUNNER_COLORS_CONFIG_FILE_NAME
    config_file
  end



  # This method will run the necessary scripts to extract images and tags
  # info from an AI file.  If config/customization.yml[ 'run_remotely' ] then
  # HTTP requests will be sent to the remote server, otherwise local
  # system calls will be executed.
  def process_original( design_template )
    extract_tags( design_template )
    extract_images( design_template )
    extract_colors( design_template )
  end


  # This method writes the design_template's prompts to a json file sitting
  # next to the original AI file.  These prompts data are used by
  # the post_processing script.
  def write_temp_prompts_file( design_template )
    path_to_ai_file = design_template.original_file.path
    Rails.logger.info 'design_templates_helper - write_temp_prompts_file()'\
      + ' - path_to_ai_file: ' + path_to_ai_file.to_s
    temp_prompts_file = path_to_prompts_file( path_to_ai_file )

    # we'll create a temporary file containing necessary info, sitting right
    # next to the original ai file.
    File.open( temp_prompts_file, 'w' ) do |f|
      f.write( design_template.prompts.to_s )
    end
  end

  def remove_prompts_file( design_template )
    path_to_ai_file = design_template.original_file.path
    temp_prompts_file = path_to_prompts_file( path_to_ai_file )
    File.delete( temp_prompts_file )
  end


  def post_process( design_template )

    return if design_template.has_been_post_processed
    design_template.has_been_post_processed = true
    design_template.save

    app_config = Rails.application.config_for( :customization )
    run_remotely = app_config[ 'run_remotely' ]

    write_temp_prompts_file( design_template )

    config_file = post_process_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = design_template.original_file.path
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_post_process_script' ]
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    #make_output_folder( design_template )

    if run_remotely
      post_process_send_remote( design_template )
    else
      post_process_system_call( design_template )
    end
    remove_prompts_file( design_template )
  end

  # This method runs the AI script that extracts all tag related information
  # from the AI file.
  def extract_tags( design_template )
    app_config = Rails.application.config_for( :customization )
    run_remotely = app_config[ 'run_remotely' ]

    config_file = tags_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = design_template.original_file.path
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_extract_tags_script' ]
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    make_output_folder( design_template )

    if run_remotely
      extract_tags_send_remote( design_template )
    else
      extract_tags_system_call( design_template )
    end
  end

  # This method runs the script that extracts all image-related information
  # from the AI file.
  def extract_images( design_template )
    app_config = Rails.application.config_for(:customization)
    run_remotely = app_config[ 'run_remotely' ]

    config_file = images_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - extract_images() - config_file: '\
      + config_file.to_s

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = design_template.original_file.path
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_extract_images_script' ]
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    make_output_folder( design_template )

    if run_remotely
      extract_images_send_remote( design_template )
    else
      extract_images_system_call( design_template )
    end
  end


  # This method runs the script that extracts all image-related information
  # from the AI file.
  def extract_colors( design_template )
    app_config = Rails.application.config_for(:customization)
    run_remotely = app_config[ 'run_remotely' ]

    config_file = colors_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - extract_colors() - config_file: '\
      + config_file.to_s

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = design_template.original_file.path
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = app_config[ 'path_to_extract_colors_script' ]
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    make_output_folder( design_template )

    if run_remotely
      extract_colors_send_remote( design_template )
    else
      extract_colors_system_call( design_template )
    end
  end


  def post_process_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - post_process_send_remote() - '\
      + 'design_template: ' + design_template.to_s
    Rails.logger.info 'design_templates_helper - post_process_send_remote() - '\
      + 'remote_host: ' + remote_host.to_s
    uri_string = remote_host + '/do_post_process?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - post_process_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def extract_tags_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
      + 'design_template: ' + design_template.to_s
    Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
      + 'remote_host: ' + remote_host.to_s
    uri_string = remote_host + '/do_extract_tags?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def extract_images_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - extract_images_send_remote()'
    uri_string = remote_host + '/do_extract_images?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - extract_images_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end


  def extract_colors_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - extract_colors_send_remote()'
    uri_string = remote_host + '/do_extract_colors?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - extract_colors_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end


  def post_process_system_call( design_template )
    Rails.logger.info 'design_templates_helper - post_process_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for(:customization)
    path = app_config[ 'path_to_runner_script' ]

    sys_com = 'ruby ' + path + ' "'\
      + post_process_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - post_process_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end

  def extract_tags_system_call( design_template )
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for(:customization)
    path = app_config[ 'path_to_runner_script' ]

    sys_com = 'ruby ' + path + ' "'\
      + tags_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end

  def extract_images_system_call( design_template )
    Rails.logger.info 'design_templates_helper - extract_images_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for( :customization )
    path = app_config[ 'path_to_runner_script' ]

    sys_com = 'ruby ' + path + ' "'\
      + images_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end


  def extract_colors_system_call( design_template )
    Rails.logger.info 'design_templates_helper - extract_colors_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for( :customization )
    path = app_config[ 'path_to_runner_script' ]

    sys_com = 'ruby ' + path + ' "'\
      + colors_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - extract_colors_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end


  def get_zombie_image_settings( images )
    image_settings = {}
    images.each do |i|
      o = { 'replace_image' => 'checked' }
      image_settings[ i ] = o
    end
    image_settings
  end

  def get_zombie_tag_settings( tags )
    tag_settings = {}
    tags.each do |t|
      o = { 'prompt' => 'Enter Stuff',
            'max_length' => '5',
            'min_length' => '1',
            'pick_color' => 'checked',
            'use_palette' => '',
            'palette_id' => '-1' }
      tag_settings[ t ] = o
    end
    tag_settings
  end

  def get_zombie_prompts( design_template )
    tags = get_tags_array( design_template )
    tag_settings = get_zombie_tag_settings( tags )

    images = get_images_array( design_template )
    image_settings = get_zombie_image_settings( images )

    o = { PROMPTS_KEY_TAG_SETTINGS => tag_settings,
          PROMPTS_KEY_IMAGE_SETTINGS => image_settings }
    o
  end

  # This method creates a fully functional template that is not associated
  # with any Illustrator file, and returns the id of that template.
  def build_zombie_template
    design_template = DesignTemplate.new( 'name' => 'zombie' )
    design_template.save
    make_output_folder( design_template )

    a = [ 'tag' ]
    tags_file = path_to_tags_file( design_template )
    File.open( tags_file, 'w' ) do |f|
      f.write( a.to_s )
    end

    a = [ 'cat' ]
    images_file = path_to_images_file( design_template )
    File.open( images_file, 'w' ) do |f|
      f.write( a.to_s )
    end

    prompts = get_zombie_prompts( design_template )
    design_template.prompts = prompts.to_json
    design_template.save
    design_template.id
  end
end

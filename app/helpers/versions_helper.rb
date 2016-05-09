# Versions Helper
module VersionsHelper
  # Every version has its own folder, used for building modified AI files.
  # This folder will contain a copy of the AI file from the template,
  # configuration files, data files, everything needed to run whatever
  # AI scripts.  Calling this method will create this folder if it doesn't
  # exist.
  def get_version_folder( version )
    app_config = Rails.application.config_for(:customization)
    versions_folder = app_config[ 'path_to_versions_folder' ]
    logger.info 'VERSIONS_HELPER - get_version_folder() - versions_folder: '\
      + versions_folder.to_s
    version_output_folder = versions_folder + version.id.to_s
    FileUtils.mkdir_p( version_output_folder )\
      unless File.directory?( version_output_folder )
    version_output_folder
  end

  # A version's values is a json obj describing all extensible settings,
  # set by the user.
  # tag_settings:
  #   tag_name:
  #     replacement_text: 'stuff'
  #     text_color: '#333333'
  #
  # image_settings:
  #   image_name:
  #     replacement_image_id: 345
  #     path: '/path/to/thing.jpg'
  #     type: 'ReplacementImage'
  #   another_name:
  #     collage_id: 333
  #     path: '/path/to/folder'
  #     type: 'Collage'
  def get_values_object( version )
    values_string = version.values
    values = {}
    logger.info 'versions_helper - get_values_object - values_string: '\
    + values_string.to_s
    if json?( values_string )
      values = JSON.parse values_string
    else
      logger.info 'VERSIONS_HELPER - get_values_object - INVALID JSON!!'
    end

    values
  end

  def get_replacement_image_id( image_name, version )
    logger.info 'VERSIONS_HELPER - get_replacement_image_id()!!'

    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?
    rep_id = ''

    if image_values
      vals = image_values[ image_name ]
      rep_id = vals[ 'replacement_image_id' ] if vals
    end

    rep_id
  end

  def get_collage_id( image_name, version )
    logger.info 'VERSIONS_HELPER - get_collage_id()!! - image_name: '\
      + image_name
    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?
    col_id = ''

    logger.info 'VERSIONS_HELPER - get_collage_id() - image_values: '\
      + image_values.to_s

    if image_values
      vals = image_values[ image_name ]
      col_id = vals[ 'collage_id' ] if vals
    end

    logger.info 'VERSIONS_HELPER - get_collage_id() - col_id: '\
      + col_id.to_s

    col_id
  end

  def get_type( image_name, version )
    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?
    type = ''
    if image_values
      vals = image_values[ image_name ]
      type = vals[ 'type' ] if vals
    end
    type
  end

  # If, within the specified version, the item named image_name
  # is associated with a Collage
  def associated_with_collage?( image_name, version )
    type = get_type( image_name, version )
    b = false
    b = true if type == 'Collage'
    logger.info 'VERSIONS_HELPER - associated_with_collage?() - image_name: '\
      + image_name.to_s
    logger.info 'VERSIONS_HELPER - associated_with_collage?() - b: '\
      + b.to_s
    b
  end

  # If, within the specified version, the item named image_name
  # is associated with a ReplacementImage
  def associated_with_replacement_image?( image_name, version )
    type = get_type( image_name, version )
    b = false
    b = true if type == 'ReplacementImage'
    logger.info 'VERSIONS_HELPER - associated_with_replacement_image?()'\
      + ' - image_name: '\
      + image_name.to_s
    logger.info 'VERSIONS_HELPER - associated_with_replacement_image?() - b: '\
      + b.to_s
    b
  end

  def get_collage( image_name, version )
    logger.info 'VERSIONS_HELPER - get_collage()'
    id = get_collage_id( image_name, version )
    logger.info 'VERSIONS_HELPER - get_collage() - id: ' + id.to_s
    co = Collage.find( id ) if is_integer?( id )
    logger.info 'VERSIONS_HELPER - get_collage() - co: ' + co.to_s
    co
  end

  def get_replacement_image( image_name, version )
    logger.info 'VERSIONS_HELPER - get_replacement_image()!!'
    id = get_replacement_image_id( image_name, version )
    ri = ReplacementImage.find( id ) if is_integer?( id )
    ri
  end

  # A version associates image_names with actual uploaded files
  def get_uploaded_file( image_name, version )
    logger.info 'VERSIONS_HELPER - get_uploaded_file !!'

    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?

    if image_values
      vals = image_values[ image_name ]
      if vals
        rep_id = vals[ 'replacement_image_id' ]
        ri = ReplacementImage.find( rep_id ) if rep_id
      end
    end
    ri.uploaded_file if ri
  end

  def get_uploaded_file_name( image_name, version )
    uploaded_file = get_uploaded_file( image_name, version )
    file_name = uploaded_file.original_filename if uploaded_file
    file_name
  end

  def get_local_image_path( image_name, version )
    uploaded_file = get_uploaded_file( image_name, version )
    replacement_path = uploaded_file.path if uploaded_file
    replacement_path
  end

  def set_tag_values( version, params )
    logger.info 'VERSIONS_HELPER - set_tag_values() - params: ' + params.to_s

    if json?( params[ 'version_data' ] )
      version_data = JSON.parse( params[ 'version_data' ] )
      tag_settings = version_data[ 'tag_settings' ]

      values = get_values_object( version )
      values[ 'tag_settings' ] = tag_settings

      version.values = values.to_json
    end

    logger.info 'VERSIONS_HELPER - set_tag_values() - version saved!'\
      if version.save
  end

  # This method removes any associates with a given image name, for a given
  # version, it does not modify the values blob so the internal state of the
  # version will be no longer consistant.
  def clear_image_associations( image_name, version )
    # get any replacement_image or collage already associated with this
    # image_name, and destroy it.
    ri = get_replacement_image( image_name, version )
    ri.destroy if ri

    co = get_collage( image_name, version )
    co.destroy if co
  end

  # This method updates a version's values json and associated ReplacementImages
  # and Collages.
  # params must contain an 'image_count' property.
  # params contain values keyed by:
  # => replacement_image<index>,
  # => image_name<index>,
  # => type<index>,
  # => query<index>
  # for each image.
  def set_image_values( version, params )
    design_template = version.design_template
    images = get_images_array( design_template )

    image_count = params[ 'image_count' ]

    image_count = if image_count != ''
                    image_count.to_i
                  else
                    0
                  end

    # get all of the uploaded files, for each create a ReplacementImage,
    # and bind it to the image_name
    image_count.times do |i|
      p_name = 'type' + i.to_s
      type = params[ p_name ]

      p_name = 'replacement_image' + i.to_s
      replacement_image = params[ p_name ]

      p_name = 'image_name' + i.to_s
      image_name = params[ p_name ]

      p_name = 'collage_query' + i.to_s
      query = params[ p_name ]

      logger.info 'VERSIONS_HELPER - set_image_values() - type: '\
        + type.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - image_name: '\
        + image_name.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - replacement_image: '\
        + replacement_image.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - query: '\
        + query.to_s

      if type == 'upload'
        if replacement_image
          my_file = replacement_image[ 'uploaded_file' ]
          logger.info 'VERSIONS_HELPER - set_image_values() - my_file: '\
            + my_file.to_s

          if my_file
            clear_image_associations( image_name, version )
            o = { uploaded_file: my_file }
            replacement_image = version.replacement_images.create( o )
            replacement_image.save

            # this will set version.values to reflect any user-set properties
            # for this version, these values will eventually be read by
            # the AI script
            add_replacement_image_to_version( replacement_image,\
                                              image_name, version )
          end # my_file
        end # replacement_image
      else
        # type = instagram collage
        logger.info 'VERSIONS_HELPER - set_image_values() - Instagram collage!'

        o = { query: query }
        clear_image_associations( image_name, version )
        collage = version.collages.create( o )
        collage.save
        add_collage_to_version( collage, image_name, version )
      end
    end # image_count times
  end

  # a version's values object matches image tags to replacement_images.
  # this method gets that version's values, and updates it with the id of
  # the replacement_image, as well as the path to the local file,
  # as this is needed by the AI script.
  def add_replacement_image_to_version( ri, image_name, version )
    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'
    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version() - ri: '\
      + ri.to_s

    values = get_values_object( version )
    image_settings = values[ 'image_settings' ]

    settings = {}
    settings[ 'replacement_image_id' ] = ri.id
    settings[ 'path' ] = ri.uploaded_file.path
    settings[ 'type' ] = 'ReplacementImage'
    image_settings[ image_name ] = settings

    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'\
      + ' - values.to_json: ' + values.to_json

    version.values = values.to_json

    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'\
      + ' - version saved!' if version.save
  end

  # a version's values object matches image tags to collages.
  # this method gets that version's values, and updates it with the id of
  # the collage, as well as the path to the local folder where a collage's
  # images are stored, as this is needed by the AI script.
  def add_collage_to_version( co, image_name, version )
    logger.info 'VERSIONS_HELPER - add_collage_to_version()'
    logger.info 'VERSIONS_HELPER - add_collage_to_version() - co: '\
      + co.to_s

    # todo, can this be part of a constructor?

    values = get_values_object( version )
    image_settings = values[ 'image_settings' ]

    settings = {}
    settings[ 'collage_id' ] = co.id
    settings[ 'path' ] = co.path
    settings[ 'type' ] = 'Collage'

    image_settings[ image_name ] = settings

    logger.info 'VERSIONS_HELPER - add_collage_to_version()'\
      + ' - values.to_json: ' + values.to_json

    version.values = values.to_json

    logger.info 'VERSIONS_HELPER - add_collage_to_version()'\
      + ' - version saved!' if version.save
  end

  # This method writes the current version's values string to a file sitting
  # right next to an AI file, named with _data.jsn.
  def write_temp_data_file( version, path_to_ai_file )
    logger.info 'versions_helper - write_temp_data_file() - path_to_ai_file: '\
      + path_to_ai_file.to_s
    temp_values_file = path_to_data_file( path_to_ai_file )

    # we'll create a temporary file containing necessary info, sitting right
    # next to the original ai file.
    File.open( temp_values_file, 'w' ) do |f|
      f.write( version.values.to_s )
    end
  end

  # This method returns the path to the configuration file for a version,
  # to be used as an argument to the run_AI_script script.  If the options
  # parameter contains version_id, that version will be used, otherwise
  # the version session variable will be used.
  def config_file_name( options = {} )
    version_id = options[ 'version_id' ]
    version = options[ 'version' ]

    logger.info 'versions_helper - config_file_name() - options: '\
      + options.to_s

    v = if version_id.nil?
          version
        else
          Version.find( version_id )
        end

    logger.info 'versions_helper - config_file_name() - v: '\
      + v.to_s

    version_output_folder = get_version_folder( v )
    config_file = version_output_folder + '/config_ai.jsn'
    config_file
  end

  def prepare_files( version, config )
    # this will put an appropriately named data file right next to the
    # source file.  The data file will contain the version.values data.
    write_temp_data_file( version, config['source file'] )

    # this will put a configuration json file in the version folder.  this file
    # tells bin/run_AI_script necessary file locations
    File.open( config_file_name( 'version' => version ), 'w' ) do |f|
      f.write( config.to_json )
    end
  end

  def process_version_system_call( version )
    logger.info 'versions_helper - system_call() - version: '\
     + version.to_s
    app_config = Rails.application.config_for(:customization)
    path = app_config['path_to_runner_script']
    logger.info 'versions_helper - system_call() - path: '\
     + path.to_s

    sys_com = 'ruby ' + path + ' "'\
      + config_file_name( 'version' => version ) + '"'
    logger.info 'versions_helper - system_call() - about to run sys_com: '\
      + sys_com.to_s
    system( sys_com )
  end

  def process_version_send_remote( version )
    logger.info 'versions_helper - process_version_send_remote()'
    uri_string = remote_host + '/do_process_version?version_id=' + version.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      logger.info 'versions_helper - process_version_send_remote() - response.code: '\
        + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def maybe_bail_out( version, tags, images )
    runai = params['runai']
    logger.info 'versions_helper - maybe_bail_out() - runai: ' + runai.to_s

    # bail out for any of these reasons
    if version.design_template.nil?
      logger.info 'versions_helper - maybe_bail_out() - '\
        + 'NOT PROCESSING, no template.'
      raise BailOutOfProcessing, 'No DesignTemplate.'
    end
    if runai != 'true'
      logger.info 'versions_helper - maybe_bail_out() - '\
        + 'NOT PROCESSING, runai not on.'
      raise BailOutOfProcessing, 'Run AI checkbox unchecked.'
    end
    if images.empty? && tags.empty?
      logger.info 'versions_helper - maybe_bail_out() - '\
        + 'NOT PROCESSING, no images and no tags.'
      raise BailOutOfProcessing, 'No extracted images or tags.'
    end
  end

  def prep_and_run( version, config )
    prepare_files( version, config )

    # custom configuration found in config/customization.yml
    app_config = Rails.application.config_for(:customization)
    run_remotely = app_config['run_remotely']

    logger.info 'versions_helper - prep_and_run() - run_remotely: '\
      + run_remotely.to_s
    logger.info 'versions_helper - prep_and_run() - config: '\
      + config.to_s

    if !run_remotely
      # run locally
      process_version_system_call( version )
    else
      # send remote HTTP request
      process_version_send_remote( version )
    end
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
  def process_version( version, tags, images )
    maybe_bail_out( version, tags, images )

    original_file = version.design_template.original_file
    original_file_path = original_file.path
    original_file_name = File.basename( original_file_path )
    original_file_base_name = File.basename( original_file_path, '.ai' )

    version_folder = get_version_folder( version )
    version_file_path = version_folder + '/' + original_file_name

    # copy the original file to the version folder, same name
    FileUtils.cp( original_file_path, version_file_path )

    if version.output_folder_path != ''
      # the user has specified an output folder
      output_folder = guarantee_final_slash( version.output_folder_path )
    else
      # the user has not specified an output folder,
      # we'll just use the version folder
      output_folder = guarantee_final_slash( version_folder )
    end

    intermediate_output = output_folder.to_s + original_file_base_name.to_s\
      + '_mod.ai'

    int_file_exist = false
    app_config = Rails.application.config_for(:customization)

    if !tags.empty?
      # There are tags to replace, we should replace tags

      path = app_config['path_to_search_replace_script']

      config = {}
      config[ 'source file' ] = version_file_path
      config[ 'script file' ] = path
      config[ 'output folder' ] = output_folder

      prep_and_run( version, config )

      # unless something went wrong, this should exist
      int_file_exist = File.exist?( intermediate_output )

    end # there are tags to replace

    if !images.empty?
      # There are images to replace, we should replace images

      config = {}
      if int_file_exist
        config[ 'source file' ] = intermediate_output
      else
        # the intermediate file does not exist, but we should still
        # replace images
        config[ 'source file' ] = version_file_path
      end

      config[ 'script file' ] = app_config['path_to_image_search_replace_script']
      config[ 'output folder' ] = output_folder

      prep_and_run( version, config )
    end # there are images to replace

  rescue => e
    logger.info 'versions_helper - Bailing Out! - ' + e.inspect
  end
end

# Application Helper
require 'net/http'
require 'uri'

module ApplicationHelper
  @versions_folder = Rails.root.to_s + '/public/system/versions/'

  class BailOutOfProcessing < StandardError
  end

  @@path_to_runner_script = Rails.root.to_s\
    + '/bin/illustrator_processing/run_AI_script.rb'
  @@path_to_extract_tags_script = Rails.root.to_s\
    + '/bin/illustrator_processing/extractTags.jsx'
  @@path_to_extract_images_script = Rails.root.to_s\
    + '/bin/illustrator_processing/extractImages.jsx'
  @@path_to_search_replace_script = Rails.root.to_s\
    + '/bin/illustrator_processing/searchAndReplace.jsx'
  @@path_to_image_search_replace_script = Rails.root.to_s\
    + '/bin/illustrator_processing/searchAndReplaceImages.jsx'
  @@path_to_quick_version_root = Rails.root.to_s + '/versions'

  def json?( s )
    # double bang forces a boolean context for whatever parse returns, without
    # changing it's boolean value
    !!JSON.parse(s)
  rescue
    false
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def is_integer? string
    true if Integer(string) rescue false
  end

  def guarantee_final_slash( folder_path )
    f = folder_path
    f = folder_path + '/' if folder_path[-1, 1] != '/'
    f
  end

  # All necessary data are written to the folder containing the original AI
  # file
  def path_to_data_file( path_to_ai_file )
    source_folder = File.dirname( path_to_ai_file )
    base_name = File.basename( path_to_ai_file, '.ai' )
    data_file = source_folder + '/' + base_name + '_data.jsn'
    data_file
  end

  def bool_display_text( b )
    t = if b.to_s == 'true'
          'yes'
        else
          'no'
        end
    t
  end

  def time_display_text(datetime)
    time = datetime.in_time_zone('Pacific Time (US & Canada)')
    time.strftime('%-m/%-d/%y: %H:%M %Z')
  end

  # This method writes the current version's values string to a file sitting
  # right next to an AI file, named with _data.jsn.
  def write_temp_data_file( path_to_ai_file )
    logger.info 'APPLICATION_HELPER - write_temp_data_file() - path_to_ai_file: '\
      + path_to_ai_file.to_s
    temp_values_file = path_to_data_file( path_to_ai_file )

    # we'll create a temporary file containing necessary info, sitting right
    # next to the original ai file.
    File.open( temp_values_file, 'w' ) do |f|
      f.write( @version.values.to_s )
    end
  end

  # This method returns the path to the configuration file for a version,
  # to be used as an argument to the run_AI_script script.  If the options
  # parameter contains version_id, that version will be used, otherwise
  # the version session variable will be used.
  def config_file_name( options = {} )
    version_id = options[ 'version_id' ]
    logger.info 'APPLICATION_HELPER - config_file_name() - options: '\
      + options.to_s

    version = if version_id.nil?
                @version
              else
                Version.find( version_id )
              end

    logger.info 'APPLICATION_HELPER - config_file_name() - version: '\
      + version.to_s

    version_output_folder = get_version_folder( version )
    config_file = version_output_folder + '/config_ai.jsn'
    config_file
  end

  def prepare_files( config )
    # this will put an appropriately named data file right next to the
    # source file.  The data file will contain the @version.values data.
    write_temp_data_file( config['source file'] )

    # this will put a configuration json file in the version folder.  this file
    # tells bin/run_AI_script necessary file locations
    File.open( config_file_name, 'w' ) do |f|
      f.write( config.to_json )
    end
  end

  def system_call( options = {} )
    logger.info 'APPLICATION_HELPER - system_call() - options: '\
     + options.to_s
    sys_com = 'ruby ' + @@path_to_runner_script + ' "'\
      + config_file_name( options ) + '"'
    logger.info 'APPLICATION_HELPER - system_call() - about to run sys_com: '\
      + sys_com.to_s
    system( sys_com )
  end

  def send_remote_run_request
    logger.info 'APPLICATION_HELPER - send_remote_run_request()'
    uri_string = local_host + '/do_run_ai?version_id=' + @version.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      logger.info 'APPLICATION_HELPER - send_remote_run_request() - response.code: '\
        + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def maybe_bail_out
    runai = params['runai']
    logger.info 'APPLICATION_HELPER - maybe_bail_out() - runai: ' + runai.to_s

    # bail out for any of these reasons
    if @version.design_template.nil?
      logger.info 'APPLICATION_HELPER - maybe_bail_out() - '\
        + 'NOT PROCESSING, no template.'
      raise BailOutOfProcessing, 'No DesignTemplate.'
    end
    if runai != 'true'
      logger.info 'APPLICATION_HELPER - maybe_bail_out() - '\
        + 'NOT PROCESSING, runai not on.'
      raise BailOutOfProcessing, 'Run AI checkbox unchecked.'
    end
    if @images.empty? && @tags.empty?
      logger.info 'APPLICATION_HELPER - maybe_bail_out() - '\
        + 'NOT PROCESSING, no images and no tags.'
      raise BailOutOfProcessing, 'No extracted images or tags.'
    end
  end

  def prep_and_run( config )
    prepare_files( config )

    # custom configuration found in config/customization.yml
    o = Rails.application.config_for(:customization)
    run_remotely = o['run_remotely']

    logger.info 'APPLICATION_HELPER - prep_and_run() - run_remotely: '\
      + run_remotely.to_s

    if !run_remotely
      # run locally
      system_call
    else
      # send remote HTTP request
      send_remote_run_request
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
  def process_version
    maybe_bail_out

    original_file = @version.design_template.original_file
    original_file_path = original_file.path
    original_file_name = File.basename( original_file_path )
    original_file_base_name = File.basename( original_file_path, '.ai' )

    version_folder = get_version_folder( @version )
    version_file_path = version_folder + '/' + original_file_name

    # copy the original file to the version folder, same name
    FileUtils.cp( original_file_path, version_file_path )

    if @version.output_folder_path != ''
      # the user has specified an output folder
      output_folder = guarantee_final_slash( @version.output_folder_path )
    else
      # the user has not specified an output folder,
      # we'll just use the version folder
      output_folder = guarantee_final_slash( version_folder )
    end

    intermediate_output = output_folder.to_s + original_file_base_name.to_s\
      + '_mod.ai'

    int_file_exist = false

    if !@tags.empty?
      # There are tags to replace, we should replace tags

      config = {}
      config[ 'source file' ] = version_file_path
      config[ 'script file' ] = @@path_to_search_replace_script
      config[ 'output folder' ] = output_folder

      prep_and_run( config )

      # unless something went wrong, this should exist
      int_file_exist = File.exist?( intermediate_output )

    end # there are tags to replace

    if !@images.empty?
      # There are images to replace, we should replace images

      config = {}
      if int_file_exist
        config[ 'source file' ] = intermediate_output
      else
        # the intermediate file does not exist, but we should still
        # replace images
        config[ 'source file' ] = version_file_path
      end
      config[ 'script file' ] = @@path_to_image_search_replace_script
      config[ 'output folder' ] = output_folder

      prep_and_run( config )
    end # there are images to replace

  rescue => e
    logger.info 'APPLICATION_HELPER - Bailing Out! - ' + e.inspect
  end
end

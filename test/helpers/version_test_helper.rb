# Version Test Helper
module VersionTestHelper
  include VersionsHelper
  include DesignTemplatesHelper

  # This method gets a template package based on the passed file name. This
  # template package is then used to get a version package.  Processing is
  # turned on, so we will attempt to generate final version output.  Both
  # packages are then checked for validity.
  #
  # options - { 'expected template status' => TEMPLATE_STATUS_... }
  def exercise_version( file_name, options )
    dt_package = get_template_package( file_name )
    v_package = get_version_package( 'dt_package' => dt_package,
                                     'do_process' => true )
    check_version( dt_package, v_package, options )
  end

  # Returns an object containing all things you'd want with a version.
  #
  # options - { 'dt_package' => design template package,
  #             'do_process' => true/false - run AI and generate output? }
  #
  # returns - { 'version' => The Version }
  def get_version_package( options )
    Rails.logger.info 'VersionTestHelper - get_version_package() - options: '\
      + options.to_s

    dt_package = options[ 'dt_package' ]
    do_process = options[ 'do_process' ]

    design_template = dt_package[ 'design_template' ]
    tags = dt_package[ 'tags' ]
    images = dt_package[ 'images' ]
    stats = dt_package[ 'stats' ]
    version_package = {}

    if stats[ 'valid' ]
      # if we have a valid template, do all of the version processing
      version = Version.new
      version.design_template = design_template
      version.save

      version.update( 'output_folder_path' => get_test_output_folder( version ) )

      if do_process
        values = get_some_values( version )
        version.values = values.to_json
        process_version( version, tags, images, 'runai' => 'true' )\
          if version.save
      end

      version_package = { 'version' => version }
    end

    version_package
  end

  def get_some_text( min, max )
    size = rand( min..max )
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    string = (0...size).map { o[rand(o.length)] }.join
    string
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

  # Build an object describing the values for a version.  Values for all of
  # the version's tags and images are created.
  def get_some_values( version )
    design_template = version.design_template
    prompts = get_prompts_object( design_template )
    tags = get_tags_array( design_template )
    images = get_images_array( design_template )
    ri = get_test_replacement_image
    ri_id = ri.id
    ri_path = get_test_replacement_image_path( ri )

    tag_settings = {}
    image_settings = {}

    tags.each do |t|
      min = prompts[ PROMPTS_KEY_TAG_SETTINGS ][ t ][ PROMPTS_KEY_MIN_L ]
      max = prompts[ PROMPTS_KEY_TAG_SETTINGS ][ t ][ PROMPTS_KEY_MAX_L ]

      text = get_some_text( min.to_i, max.to_i )
      o = { 'replacement_text' => text,
            'text_color' => '#333333' }
      tag_settings[ t ] = o
    end

    images.each do |i|
      o = { VERSION_VALUES_KEY_RI_ID => ri_id,
            VERSION_VALUES_KEY_PATH => ri_path.to_s,
            VERSION_VALUES_KEY_TYPE => 'ReplacementImage' }
      image_settings[ i ] = o
    end

    o = { VERSION_VALUES_KEY_TAG_SETTINGS => tag_settings,
          VERSION_VALUES_KEY_IMAGE_SETTINGS => image_settings }

    Rails.logger.info( 'version_test_helper - get_some_values() - o: '\
      + JSON.pretty_generate( o ) )

    o
  end

  def get_test_output_folder( version )
    path = Rails.root.to_s + '/test/output/version_' + version.id.to_s
    path
  end


  def get_original_file_base_name( version )
    original_file = version.design_template.original_file
    original_file_path = original_file.path
    original_file_base_name = File.basename( original_file_path, '.ai' )
    original_file_base_name
  end

  def get_final_output_file_name( version )
    original_file_base_name = get_original_file_base_name( version )
    final_output_file_base_name = original_file_base_name + '_final'
    final_output_file_name = final_output_file_base_name + '.ai'
    final_output_file_name
  end

  def extract_strings( version )
    final_output_file_name = get_final_output_file_name( version)
    output_folder = version.output_folder_path

    final_output_file_path = output_folder + '/' + final_output_file_name

    Rails.logger.info( 'version_test_helper - extract_strings() - '\
      + ' final_output_file_path: ' + final_output_file_path )

    app_config = Rails.application.config_for(:customization)

    path = app_config[ 'path_to_extract_all_text_script' ]

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = final_output_file_path
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = path
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
    config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = 'strings'

    prep_and_run( version, config )
  end

  def get_strings_file_path( version )
    original_file_base_name = get_original_file_base_name( version )
    output_folder = version.output_folder_path
    strings_file_name = original_file_base_name + '_final_all_strings.jsn'
    strings_file_path = output_folder + '/' + strings_file_name
    strings_file_path
  end

  # Verify that all of the replacement strings found in Version.values are
  # present in the final ai output file.
  # generates an _all_string.jsn file containing all strings found in the
  # specified ai file.
  def check_strings( version )
    extract_strings( version )

    values = get_values_object( version )
    tag_settings = values[ VERSION_VALUES_KEY_TAG_SETTINGS ]

    strings_file_path = get_strings_file_path( version )
    strings = load_array_file( strings_file_path )

    tag_settings.each do |t|
      rep_text = t[ 1 ][ VERSION_VALUES_KEY_REPLACEMENT_TEXT ]

      assert( strings.include?( rep_text ), 'Replacement text not found: '\
        + rep_text )
    end
  end

  # Validate as much as possible that this version is as it should be.
  def check_version( dt_package, v_package, options )
    version = v_package[ 'version' ]
    dt_stats = dt_package[ 'stats' ]
    status = dt_stats[ DESIGN_TEMPLATE_STATS_KEY_STATUS ]
    expected_status = options[ 'expected template status' ]

    assert_equal( status, expected_status, 'Unexpected status' )

    if !version.nil?

      check_strings( version )

      output_folder = version.output_folder_path
      original_file = version.design_template.original_file
      original_file_path = original_file.path
      original_file_base_name = File.basename( original_file_path, '.ai' )

      output_contents = Dir.entries( output_folder.to_s )

      Rails.logger.info( 'version_test_helper - check_version()'\
        + ' - output_folder: ' + output_folder.to_s )
      Rails.logger.info( 'version_test_helper - check_version()'\
        + ' - output_contents: ' + output_contents.to_s )

      final_output_file_base_name = original_file_base_name + '_final'
      assert( output_contents.include?( final_output_file_base_name + '.ai' ),\
              'Final .ai output file not found.' )
      assert( output_contents.include?( final_output_file_base_name + '.jpg' ),\
              'Final .jpg output file not found.' )
    else
      # no version was created.
      Rails.logger.info( 'version_test_helper - check_version()'\
        + ' - no version made, dt stats: ' + JSON.pretty_generate( dt_stats ) )
    end
  end
end

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
        process_version( version, 'runai' => 'true' )\
          if version.save
      end

      version_package = { 'version' => version }
    end

    version_package
  end

  # Get random text between min and max chars in length
  def get_some_text( min, max )
    Rails.logger.info 'version_test_helper - get_some_text() - min: ' + min.to_s
    Rails.logger.info 'version_test_helper - get_some_text() - max: ' + max.to_s
    return '' if min >= max
    size = rand( min..max )
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    string = (0...size).map { o[rand(o.length)] }.join
    string
  end

  # This method gets a color that can be translated to cmyk and back with a
  # difference < 30, a totally arbitrary value. I looked at calculated
  # differences for random colors and most of the diffs were < 100
  def get_a_good_color
    good_colors = [ '#05bcbe', '#5e9f67', '#8d2f63', '#e0edd3', '#3fa524',
                    '#bb3065', '#05c4ea', '#a7a582', '#70e878', '#5d6cf6',
                    '#4cc667', '#0cfdfd', '#064e6b', '#83a864', '#ddaf53',
                    '#cd5470', '#fe6aab', '#e58591' ]
    good_colors.sample
  end

  # This method gets a random hex color.  Some of these will not map to cmyk.
  def get_a_color
    color = '%06x' % (rand * 0xffffff)
    color = '#' + color
    color
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

      # Good colors are colors that can be closely translated cmyk to rgb
      color = get_a_good_color
      o = { VERSION_VALUES_KEY_REPLACEMENT_TEXT => text,
            VERSION_VALUES_KEY_TEXT_COLOR => color }
      tag_settings[ t ] = o
    end

    images.each do |i|
      o = { VERSION_VALUES_KEY_RI_ID => ri_id,
            VERSION_VALUES_KEY_PATH => ri_path.to_s,
            VERSION_VALUES_KEY_TYPE => IMAGE_TYPE_REPLACEMENT_IMAGE }
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

  # Pass base-10 integer values for red, green, blue.  Get #rrggbb
  def get_hex_code( red, green, blue )
    r = '%02x' % red
    g = '%02x' % green
    b = '%02x' % blue
    s = '#' + r + g + b
    s
  end

  # Compare two hex color codes, returns true if they're reasonably close.
  def colors_close_enough( c1, c2 )
    r1 = c1[ 1..2 ]
    r2 = c2[ 1..2 ]
    g1 = c1[ 3..4 ]
    g2 = c2[ 3..4 ]
    b1 = c1[ 5..6 ]
    b2 = c2[ 5..6 ]

    diff = ( r1.to_i - r2.to_i ).abs + ( g1.to_i - g2.to_i ).abs\
      + ( b1.to_i - b2.to_i ).abs

    if diff < 30
      Rails.logger.info( 'colors_close_enough() - GOOD COLOR!!!! c1: '\
        + c1.to_s + ' -- c2: ' + c2.to_s )
      Rails.logger.info( 'colors_close_enough() - diff: ' + diff.to_s )
      return true
    end
    false
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
    strings_object = load_array_file( strings_file_path )

    tag_settings.each do |t|
      rep_text = t[ 1 ][ VERSION_VALUES_KEY_REPLACEMENT_TEXT ]
      rep_color = t[ 1 ][ VERSION_VALUES_KEY_TEXT_COLOR ]

      actual_index = strings_object.find_index\
        { |item| item['string'] == rep_text }

      # Make sure the replacement string exists in the final ai file.
      assert( actual_index, 'Replacement text not found: ' + rep_text )

      actual_string_data = strings_object[ actual_index ] if actual_index
      actual_hex = get_hex_code( actual_string_data[ 'r'],\
                                 actual_string_data[ 'g' ],\
                                 actual_string_data[ 'b' ] )

      # Make sure the color of the replacements string is close enough to
      # the replacement string color.
      description = 'Colors not close enough! rep_color: ' + rep_color.to_s\
        + ', actual_hex: ' + actual_hex.to_s + ' --- values: '\
        + JSON.pretty_generate( values ) + ' --- output_folder: '\
        + version.output_folder_path

      # This method checks to see if the replacement color is pretty close
      # to the requested color.  Generally they will be close, but some rgb
      # colors do not map to cmyk colors.  Those colors will cause this test
      # to fail.
      assert( colors_close_enough( rep_color, actual_hex ), description )
    end
  end

  # Validate as much as possible that this version is as it should be.
  def check_version( dt_package, v_package, options )
    version = v_package[ 'version' ]
    dt_stats = dt_package[ 'stats' ]
    status = dt_stats[ DESIGN_TEMPLATE_STATS_KEY_STATUS ]
    expected_status = options[ 'expected template status' ]

    assert_equal( status, expected_status, 'Unexpected status!' )

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

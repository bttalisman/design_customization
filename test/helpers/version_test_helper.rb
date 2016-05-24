# Version Test Helper
module VersionTestHelper
  include VersionsHelper

  def exercise_version( file_name )
    dt_package = get_template_package( file_name )
    v_package = get_version_package( 'dt_package' => dt_package,
                                     'do_process' => true )

    check_version( dt_package, v_package )
  end

  def get_version_package( options )
    Rails.logger.info 'VersionTestHelper - get_version_package() - options: '\
      + options.to_s

    dt_package = options[ 'dt_package' ]
    do_process = options[ 'do_process' ]

    design_template = dt_package[ 'design_template' ]
    tags = dt_package[ 'tags' ]
    images = dt_package[ 'images' ]

    version = Version.new
    version.design_template = design_template
    version.save

    version.update( 'output_folder_path' => get_test_output_folder( version ) )

    if do_process then
      values = get_some_values( version )
      version.values = values.to_json
      process_version( version, tags, images, 'runai' => 'true' ) if version.save
    end

    version_package = { 'version' => version }
    version_package
  end


  #####################################################################
  # Helper functions for setting up Version.values
  #
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
    tags = get_tags_array( design_template )
    images = get_images_array( design_template )
    ri = get_test_replacement_image
    ri_id = ri.id
    ri_path = get_test_replacement_image_path( ri )

    Rails.logger.info( 'version_test_helper - get_some_values() - tags: ' + tags.to_s )
    Rails.logger.info( 'version_test_helper - get_some_values() - images: ' + images.to_s )

    tag_settings = {}
    image_settings = {}

    tags.each { |t|
      o = { 'replacement_text' => 'some text',
            'text_color' => '#333333' }
      tag_settings[ t ] = o
    }

    images.each { |i|
      o = { 'replacement_image_id' => ri_id,
            'path' => ri_path.to_s,
            'type' => 'ReplacementImage' }
      image_settings[ i ] = o
    }

    o = { 'tag_settings' => tag_settings,
          'image_settings' => image_settings }

    Rails.logger.info( 'version_test_helper - get_some_values() - o: ' + o.to_s )

    o
  end

  def get_test_output_folder( version )
    path = Rails.root.to_s + '/test/output/version_' + version.id.to_s
    path
  end

  # Validate as much as possible that this version is good
  def check_version( dt_package, v_package )

    version = v_package[ 'version' ]
    dt = dt_package[ 'design_template' ]

    has_images = images?( dt )
    has_tags = tags( dt )

    version_folder = get_version_folder( version )
    output_folder = version.output_folder_path

    # todo check for presence of all files
    Rails.logger.info( 'version_test_helper - check_version()'\
      + ' - version_folder: ' + version_folder.to_s )

    Rails.logger.info( 'version_test_helper - check_version()'\
      + ' - output_folder: ' + output_folder.to_s )

  end
end

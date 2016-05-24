require_relative '../../app/helpers/partials_helper'

# Partial Test Helper
module PartialTestHelper
  include PartialsHelper

  # images and tags should be arrays representing the images and tags
  # extracted from an ai file.  Values should be json providing all necessary
  # data for the version UI to present to the customer.
  def assert_valid_values( images, tags, image_values, tag_values )

    Rails.logger.info 'PartialTestHelper - assert_valid_values() - images: '\
      + images.to_s
    Rails.logger.info 'PartialTestHelper - assert_valid_values() - tags: '\
      + tags.to_s
    Rails.logger.info 'PartialTestHelper - assert_valid_values() - image_values: '\
      + image_values.to_s
    Rails.logger.info 'PartialTestHelper - assert_valid_values() - tag_values: '\
      + tag_values.to_s

    images.each do |i|
      Rails.logger.info 'PartialTestHelper - assert_valid_values() - i: '\
        + i.to_s
      assert_not_empty( image_values[ i ], 'Missing image value.' )
    end

    tags.each do |t|
      assert_not_empty( tag_values[ t ], 'Missing tag value.' )
    end
  end

  def exercise_dt_settings( file_name )
    dt_package = get_template_package( file_name )
    dt_id = dt_package[ 'design_template' ].id
    images = dt_package[ 'images' ]
    tags = dt_package[ 'tags' ]

    get( 'design_template_settings', id: dt_id )
    assert_response :success

    values = assigns( :values )
    image_values = values[ 'image_settings' ]
    tag_values = values[ 'tag_settings' ]

    assert_valid_values( images, tags, image_values, tag_values )
  end

  def exercise_version_settings( file_name )
    dt_package = get_template_package( file_name )
    dt = dt_package[ 'design_template' ]
    dt_id = dt.id

    # Get a version based on this template, don't process it and no extracted
    # settings will be set
    v_package = get_version_package( 'dt_package' => dt_package, 'do_process' => false )
    version = v_package[ 'version' ]

    # Get request to partials_controller#version_settings
    get( 'version_settings', template_id: dt_id, version_id: version.id )
    assert_response :success

    tags = assigns( :tags )
    images = assigns( :images )
    image_values = assigns( :image_values )
    tag_values = assigns( :tag_values )

    # No values have been set so these should both be empty objects
    assert_equal( {}, image_values, 'Image values not empty object.' )
    assert_equal( {}, tag_values, 'Tag values not empty object.' )

    # Update the version with some values
    values = get_some_values( version )
    params = { id: version.id,
               version: { name: 'test name',
                          design_template_id: dt_id,
                          values: values.to_json } }

    raw_get( action: :update,
             controller: VersionsController.new,
             params: params )

    # Get request to partials_controller#version_settings
    get( 'version_settings', template_id: dt_id, version_id: version.id )
    assert_response :success

    image_values = assigns( :image_values )
    tag_values = assigns( :tag_values )

    assert_valid_values( images, tags, image_values, tag_values )
  end

  def exercise_get_palettes( file_name )
    dt_package = get_template_package( file_name )
    dt = dt_package[ 'design_template' ]

    palettes = get_palettes( dt )
  end
end

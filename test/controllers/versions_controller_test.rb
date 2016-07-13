require_relative '../helpers/test_helper'
require_relative '../helpers/version_test_helper'
require_relative '../helpers/design_template_test_helper'

# VersionsControllerTest
class VersionsControllerTest < ActionController::TestCase
  # It seems that these test helpers need to be required, as above.  No idea
  # why. todo - figure this out.
  include TestHelper
  include VersionTestHelper
  include DesignTemplateTestHelper

  include ApplicationHelper
  include DesignTemplatesHelper
  include VersionsHelper

  # These tests run through the entire process of making a version of a
  # design.  These ai files are valid for templating, and each of these
  # exercises is expected to successfully generate all version output.
  test 'soup to nuts' do
    options = { 'expected template status' => TEMPLATE_STATUS_SUCCESS }
    #exercise_version( 'one_tag_one_image.ai', options )
    #exercise_version( '300x300Items.ai', options )
    #exercise_version( 'SingleTag-V1S12.ai', options )
    #exercise_version( 'tags_and_images.ai', options )
    #exercise_version( 'many_tags.ai', options )
  end

  # These tests attempt to make templates from ai files that
  # have errors or are otherwise incomplete.
  test 'bad template files' do
    options = { 'expected template status' => TEMPLATE_STATUS_DUP_TAGS }
    #exercise_version( 'duplicate_keys.ai', options )

    options = { 'expected template status' => TEMPLATE_STATUS_NOT_A_TEMPLATE }
    #exercise_version( 'no_tags_no_images.ai', options )
  end

  # Build a zombie template, build a version, get prompts, add a collage
  # for each image in propmts, test image-related helper methods, clear_token
  # associations, verify that the associations are cleared.
  test 'image helpers with collages' do
    id = build_zombie_template
    dt = DesignTemplate.find( id )
    assert( dt, 'Failed to make a zombie template' )

    version = Version.new( name: 'zombie', output_folder_path: '',\
      design_template_id: id )
    version.save
    assert( version, 'Failed to make a zombie version' )

    prompts = get_prompts_object( dt )
    image_settings = prompts[ PROMPTS_KEY_IMAGE_SETTINGS ]

    image_settings.each { |i|
      o = { query: 'bob' }
      collage = version.collages.create( o )
      add_collage_to_version( collage, i[0].to_s, version )
    }

    image_settings.each { |i|
      assert( !associated_with_replacement_image?( i[0].to_s, version ),\
              'associated_with_replacement_image?() wrongly returned true.' )
      assert( associated_with_collage?( i[0].to_s, version ),\
              'associated_with_collage?() wrongly returned false.' )

      co = get_collage( i[0].to_s, version )
      ri = get_replacement_image( i[0].to_s, version )

      assert( co.is_a?( Collage ), 'get_collage() did not return a collage.' )
      assert( ri.nil?, 'get_collage() did not return nil.' )
    }

    Rails.logger.info 'versions_controller_test - image_helpers_with_collages()'\
      + ' - About to clear image associations.'
    image_settings.each { |i|
      clear_image_associations( i[0].to_s, version )
    }

    Rails.logger.info 'versions_controller_test - image_helpers_with_collages()'\
      + ' - About to re-test associated_with...() methods.'
    Rails.logger.info 'versions_controller_test - image_helpers_with_collages()'\
      + ' - values: ' + JSON.pretty_generate( get_values_object( version ) )
    image_settings.each { |i|
      assert( !associated_with_replacement_image?( i[0].to_s, version ),\
              'associated_with_replacement_image?() wrongly returned true.' )
      assert( !associated_with_collage?( i[0].to_s, version ),\
              'associated_with_collage?() wrongly returned true.' )

      co = get_collage( i[0].to_s, version )
      ri = get_replacement_image( i[0].to_s, version )

      assert( co.nil?, 'get_collage() should have returned nil.' )
      assert( ri.nil?, 'get_replacement_image() should have returned nil.' )
    }
  end
end

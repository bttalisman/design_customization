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
    exercise_version( 'tags_and_images.ai', options )
  end

  # These tests attempt to make templates from ai files that
  # have errors or are otherwise incomplete.
  test 'bad template files' do
    options = { 'expected template status' => TEMPLATE_STATUS_DUP_TAGS }
    #exercise_version( 'duplicate_keys.ai', options )

    options = { 'expected template status' => TEMPLATE_STATUS_NOT_A_TEMPLATE }
    #exercise_version( 'no_tags_no_images.ai', options )
  end
end

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

  # This test runs through the entire process of making a version of a
  # design containing a single tag and a single image.  A DesignTemplate
  # is built, items are extracted, a Version is built, its values are
  # generated, and final AI output is generated
  test 'soup to nuts' do
    exercise_version( 'one_tag_one_image.ai' )
  end
end

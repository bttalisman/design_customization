require_relative '../helpers/test_helper'
require_relative '../helpers/partial_test_helper'
require_relative '../helpers/design_template_test_helper'

class PartialsControllerTest < ActionController::TestCase
  include TestHelper
  include DesignTemplateTestHelper
  include PartialTestHelper
  include ApplicationHelper
  include DesignTemplatesHelper

  test 'designTemplate settings' do
#    exercise_settings( 'one_tag_one_image.ai' ) # one tag, one image
#    exercise_settings( '300x300Items.ai' ) # one image many times, no tags
    exercise_settings( 'tags_and_images.ai' ) # two tags, two repeated images

  end
end

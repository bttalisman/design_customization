require_relative '../helpers/test_helper'
require_relative '../helpers/partial_test_helper'
require_relative '../helpers/design_template_test_helper'
require_relative '../helpers/version_test_helper'

class PartialsControllerTest < ActionController::TestCase
  # It seems that these test helpers need to be required, as above.  No idea
  # why. todo - figure this out.
  include TestHelper
  include DesignTemplateTestHelper
  include VersionTestHelper
  include PartialTestHelper

  include ApplicationHelper
  include DesignTemplatesHelper
  include PartialsHelper

  # The partials#design_template_settings action loads
  # all data needed to edit extracted settings of a DesignTemplate.  This
  # action gets called through an ajax call executed by the
  # design_templates#edit view.
  #
  # The following tests create DesignTemplates, load the specified file,
  # extract image and tag names, get dummy values and post these to
  # design_templates#all_settings action, which stores these as the
  # DesignTemplate.values column, make a get request to the
  # partials#design_template_settings action, and then verify that the
  # values column contains necessary keys.
  test 'designTemplate settings' do
    #exercise_dt_settings( 'one_tag_one_image.ai' ) # one tag, one image
    #exercise_dt_settings( '300x300Items.ai' ) # one image many times, no tags
    #exercise_dt_settings( 'tags_and_images.ai' ) # two tags, two repeated images
  end

  # The partials#version_settings action loads all the data needed to edit
  # extracted settings of a Version.  This action gets called through an
  # ajax call executed by the versions#edit view.
  #
  # The following tests do everything the 'designTemplate settings' test does,
  # in order to create DesignTemplates, in addition, these tests create
  # a Version associated with the DesignTemplate, issue a post to
  # VersionsController#update without any values, get some dummy values
  # issue a post to update again, and then verify that image and tag values
  # for the version correspond with image and tag arrays associated with
  # the DesignTemplate.
  test 'version settings' do
    #exercise_version_settings( 'one_tag_one_image.ai' )
    #exercise_version_settings( '300x300Items.ai' )
    #exercise_version_settings( 'tags_and_images.ai' )
  end

  test 'get palettes' do
    exercise_get_palettes( 'tags_and_images.ai' )
  end
end

require_relative '../helpers/test_helper'
require_relative '../helpers/version_test_helper'
require_relative '../helpers/design_template_test_helper'

# VersionsControllerTest
class VersionsControllerTest < ActionController::TestCase
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
  test 'one tag one image process' do
    design_template = design_templates( :one_tag_one_image )
    dt_id = design_template.id
    process_template( design_template, 'one_tag_one_image.ai' )

    tags = get_tags_array( design_template )
    images = get_images_array( design_template )
    extracted_settings = get_some_extracted_settings( design_template )
    general_settings = {}

    o = { 'extracted_settings' => extracted_settings,
          'general_settings' => general_settings }

    raw_post( action: :all_settings,
              controller: DesignTemplatesController.new,
              params: { 'id' => dt_id },
              body: o.to_json )

    version = versions( :one_tag_one_image )
    version.update( 'output_folder_path' => get_test_output_folder( version ) )
    values = get_some_values( version )
    version.values = values.to_json


    process_version( version, tags, images, 'runai' => 'true' ) if version.save
    check_version( version, tags, images )
  end
end

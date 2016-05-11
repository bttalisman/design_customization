require_relative '../helpers/test_helper'
require_relative '../helpers/design_template_test_helper'

class DesignTemplatesControllerTest < ActionController::TestCase
  include TestHelper
  include DesignTemplateTestHelper
  include ApplicationHelper
  include DesignTemplatesHelper

  test 'extensible settings' do
    design_template = design_templates( :one_tag )
    dt_id = design_template.id
    process_template( design_template, 'one_tag_one_image.ai' )

    extracted_settings = get_some_extracted_settings( design_template )
    general_settings = {}

    o = { 'extracted_settings' => extracted_settings,
          'general_settings' => general_settings }

    raw_post( action: :all_settings,
              params: { 'id' => dt_id },
              body: o.to_json )
  end
end

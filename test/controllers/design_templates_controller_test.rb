require_relative '../helpers/test_helper'

class DesignTemplatesControllerTest < ActionController::TestCase
  include TestHelper
  include DesignTemplatesHelper

  test 'extensible settings' do
    design_template = design_templates( :one_tag )
    dt_id = design_template.id
    # process_template( design_template, 'SingleTag-V1S12.ai' )

    raw_post( :all_settings, { 'id' => dt_id }, { 'foo' => 'bar' }.to_json )

  end
end

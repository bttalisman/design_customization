require_relative '../helpers/test_helper'

# DesignTemplate Test
class DesignTemplateTest < ActiveSupport::TestCase

  include TestHelper
  include DesignTemplatesHelper

  test 'one tag' do

    design_template = design_templates( :one_tag )
    process_template( design_template, 'SingleTag-V1S12.ai' )

  end
end

require_relative '../helpers/test_helper'

# DesignTemplate Test
class DesignTemplateTest < ActiveSupport::TestCase

  include TestHelper
  include DesignTemplatesHelper

  test 'one tag' do
    logger = Logger.new(STDOUT)
    @design_template = DesignTemplate.new
    @design_template.original_file = sample_file( 'SingleTag-V1S12.ai' )
    process_original
  end


end

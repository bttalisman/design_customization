require_relative '../helpers/test_helper'

# DesignTemplate Test
class DesignTemplateTest < ActiveSupport::TestCase

  include TestHelper
  include DesignTemplatesHelper

  test 'one tag' do

    Rails.logger = Logger.new(STDOUT)

    design_template = design_templates( :one )

    file = sample_file( 'SingleTag-V1S12.ai' )

    design_template.orig_file_path = file.path.to_s
    design_template.original_file = file
    design_template.original_file.\
      instance_write(:content_type, 'application/postscript')

    build_test_template( design_template, file )

    if design_template.save!
      puts 'successful save'
      process_original( design_template )
    else
      puts 'failed save'
    end

  end
end

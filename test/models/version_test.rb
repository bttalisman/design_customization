require_relative '../helpers/test_helper'
require_relative '../helpers/version_test_helper'
require_relative '../helpers/design_template_test_helper'


class VersionTest < ActiveSupport::TestCase
  include TestHelper
  include VersionTestHelper
  include DesignTemplateTestHelper
  include DesignTemplatesHelper

  test 'one tag' do
    version = versions( :one_tag )

    app_config = Rails.application.config_for(:customization)

    design_template = design_templates( :one_tag )
    process_template( design_template, 'SingleTag-V1S12.ai' )

    # config_hash = { design_template_id: template_id }
    # @version = Version.new( config_hash )

    version.save

    version_folder_path = app_config[ 'path_to_versions_folder' ]\
      + '/version_' + version.id.to_s + '/'
    version.output_folder_path = version_folder_path
    version.save

  end
end

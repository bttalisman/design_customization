require 'test_helper'
require_relative '../helpers/test_helper'
require_relative '../helpers/version_test_helper'
require_relative '../helpers/design_template_test_helper'

class CollagesControllerTest < ActionController::TestCase
  include TestHelper
  include VersionTestHelper
  include DesignTemplateTestHelper

  include ApplicationHelper
  include DesignTemplatesHelper  
  include VersionsHelper

  
  test 'collage basics' do

    id = build_zombie_template
    
  end
end

require 'test_helper'

# Home Controller Test
class HomeControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
  end
end

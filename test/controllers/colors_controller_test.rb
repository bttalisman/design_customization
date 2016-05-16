require_relative '../helpers/test_helper'

# Colors Controlle Test
class ColorsControllerTest < ActionController::TestCase
  include TestHelper

  test 'update action' do
    c = Color.new
    c.save
    id = c.id

    get( :update, { 'id' => id,
                    'color' => { 'hex_code' => '#aaaaaa',
                                 'description' => 'test desc' } } )

    path = color_path( c.id )
    Rails.logger.info 'ColorsControllerTest - update_action() - path: '\
      + path.to_s
    assert_redirected_to path
  end

  test 'delete all' do
    10.times do
      c = Color.new
      c.save
    end
    get( :delete_all, {} )
    assert_response :success
  end
end

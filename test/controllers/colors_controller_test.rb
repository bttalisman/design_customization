require_relative '../helpers/test_helper'

# Colors Controlle Test
class ColorsControllerTest < ActionController::TestCase
  # It seems that these test helpers need to be required, as above.  No idea
  # why. todo - figure this out.
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
    get( :delete_all, {} )
    assert_response :success

    10.times do
      c = Color.new
      c.save
    end

    count = Color.all.count
    assert_equal( 10, count, 'Unexpected color count.' )

    get( :delete_all, {} )
    assert_response :success

    count = Color.all.count
    assert_equal( 0, count, 'Unexpected color count.' )
  end

  test 'create behavior' do
    original_count = Color.all.count
    color_params = { color: { description: 'test color',
                              hex_code: '#000000' } }

    get( :create, color_params )
    assert_redirected_to( @color )

    new_count = Color.all.count

    assert_equal( original_count + 1, new_count, 'Unexpected color count.' )
  end

end

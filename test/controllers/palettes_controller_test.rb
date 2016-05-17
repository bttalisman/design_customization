require_relative '../helpers/test_helper'

# Palettes Controller Test
class PalettesControllerTest < ActionController::TestCase
  include TestHelper

  test 'update action' do
    p = Palette.new
    p.save
    id = p.id

    get( :update, id: id,
                  palette: { description: 'test palette description',
                             name: 'test name' } )

    path = palette_path( p.id )
    assert_redirected_to path
    assert( p.save, 'Save failed.' )
  end

  test 'delete all' do
    get( :delete_all, {} )
    assert_response :success

    10.times do
      p = Palette.new
      p.save
    end

    count = Palette.all.count
    assert_equal( 10, count, 'Unexpected palette count.' )

    get( :delete_all, {} )
    assert_response :success

    count = Palette.all.count
    assert_equal( 0, count, 'Unexpected palette count.' )
  end

  test 'create behavior' do
    original_count = Palette.all.count
    palette_params = { palette: { name: 'test name',
                                  description: 'test palette' } }

    get( :create, palette_params )
    assert_redirected_to( @palette )

    new_count = Palette.all.count

    assert_equal( original_count + 1, new_count, 'Unexpected palette count.' )
  end

  test 'add and remove behavior' do
    p = Palette.new
    p.save
    p_id = p.id

    # Add 10 colors
    10.times do
      c = Color.new
      c.save

      get( :add, id: p_id,
                 color_id: c.id )
      assert_response :success
    end
    assert_equal( 10, p.colors.count, 'Unexpected color count.' )

    # Remove the first one
    id_to_remove = p.colors.first.id
    get( :remove, id: p_id,
                  color_id: p.colors.first.id )
    assert_response :success
    assert_equal( 9, p.colors.count, 'Unexpected color count.' )

    # Remove all colors
    get( :remove_all, id: p_id )
    assert_response :success
    assert_equal( 0, p.colors.count, 'Unexpected color count.' )

    assert( p.save, 'Save failed.' )
  end
end

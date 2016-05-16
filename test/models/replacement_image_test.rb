require_relative '../helpers/test_helper'

# Test ReplacementImage model
class ReplacementImageTest < ActiveSupport::TestCase
  include TestHelper
  test 'filename' do
    file = sample_file( 'one_tag_one_image.ai' )
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save
    fn = ri.file_name

    assert_equal( 'one_tag_one_image.ai', fn,\
                  'ReplacementImage.filename function isnt working!' )
  end
end

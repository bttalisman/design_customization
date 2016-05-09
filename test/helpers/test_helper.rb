# Test Helper
module TestHelper
  def sample_file(filename = 'one_tag_one_image.ai')
    s = 'test/fixtures/original_files/' + filename
    File.new(s)
  end
end

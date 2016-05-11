# Test Helper
module TestHelper
  def sample_file( filename )
    s = 'test/fixtures/original_files/' + filename
    File.new(s)
  end

  # Post body data to specified controller/action
  def raw_post( options )
    Rails.logger.info 'test_helper - raw_post() - options: ' + options.to_s

    action = options[ :action ]
    body = options[ :body ]
    params = options[ :params ]
    controller = options[ :controller ]

    if !controller.nil?
      old_controller = @controller
      @controller = controller
    end

    @request.env['RAW_POST_DATA'] = body
    response = post(action, params)
    @request.env.delete('RAW_POST_DATA')

    @controller = old_controller if !controller.nil?

    response
  end

  def get_test_replacement_image()
    ri = ReplacementImage.new
    file = sample_file( 'bact.jpg' )
    ri.uploaded_file = file
    ri.save
    ri
  end

  # Fake-o ReplacementImages won't be in the folder struct built by paperclip,
  # so we'll just return the path to the fixture folder
  def get_test_replacement_image_path( ri )
    name = ri.file_name
    path = Rails.root.to_s + '/test/fixtures/original_files/' + name
    Rails.logger.info 'test_helper - get_test_replacement_image_path() - '\
      + path.to_s
    path
  end
end

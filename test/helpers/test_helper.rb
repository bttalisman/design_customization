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

  def raw_get( options )
    Rails.logger.info 'test_helper - raw_get() - options: ' + options.to_s

    action = options[ :action ]
    params = options[ :params ]
    controller = options[ :controller ]

    if !controller.nil?
      old_controller = @controller
      @controller = controller
    end

    response = get(action, params)

    @controller = old_controller if !controller.nil?

    response
  end

  # Get a ReplacementImage containing a random image from
  # /test/fixtures/original_files/replacement_images
  def get_test_replacement_image()
    path = Rails.root.to_s + '/test/fixtures/original_files/replacement_images'
    Rails.logger.info 'test_helper - get_test_replacement_image() - path: '\
      + path.to_s
    folder_contents = Dir.entries( path )
    file = File.new( path + '/' + folder_contents.sample )
    file = File.new( path + '/' + folder_contents.sample )\
      while File.directory?( file.path )
    Rails.logger.info 'test_helper - get_test_replacement_image() - file.path: '\
      + file.path.to_s
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save
    ri
  end

  # Fake-o ReplacementImages won't be in the folder struct built by paperclip,
  # so we'll just return the path to the fixtures folder
  def get_test_replacement_image_path( ri )
    name = ri.uploaded_file.original_filename
    path = Rails.root.to_s + '/test/fixtures/original_files/replacement_images/' + name
    Rails.logger.info 'test_helper - get_test_replacement_image_path() - '\
      + path.to_s
    path
  end

  def random_palette()
    offset = rand( Palette.count )
    rand_record = Palette.offset( offset ).first
    rand_record
  end
end

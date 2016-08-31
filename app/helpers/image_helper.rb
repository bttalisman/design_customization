
module ImageHelper

  def path_to_image?( path )
    extension = File.extname( path )

    if( (extension == '.jpg') ||
        (extension == '.jpeg') )
      return true
    end
    false
  end

  def path_to_zip?( path )
    extension = File.extname( path )
    if( extension == '.zip' )
      return true
    end
    false
  end


  # This method resizes all of the images extracted from a ReplacementImage
  # for which the uploaded_file is a zip archive.  It is expected that the
  # images have already been extracted into a 'extracted' subfolder.
  def resize_images_from_zip( design_template, ri )
    Rails.logger.info 'image_helper - resize_images_from_zip()'

    # Note, we need to verify that uploaded file itself is a zip.
    # Calling ri.get_path() returns a path to the folder containing extracted
    # items.
    path = ri.uploaded_file.path.to_s
    return if !path_to_zip?( path )
    extracted_folder = ri.get_path()
    return if !File.exists?( extracted_folder )

    Dir.entries( extracted_folder ).each do |name|
      Rails.logger.info 'image_helper - resize_images_from_zip() - name: '\
        + name.to_s
      # skip folders
      next if File.directory? name
      next if !path_to_image?( name )

      file_path = File.join( extracted_folder, name )
      resize_image_from_image_file( design_template, ri, file_path )
    end
  end


  def resize_image_from_image_file( design_template, ri, path )
    return if !path_to_image?( path )

    image_name = ri.image_name
    Rails.logger.info 'image_helper - resize_image_from_image_file() - image_name: '\
      + image_name.to_s

    # Get prompts associated with this replaementImage, see if it's
    # to be fitted.
    prompts = get_prompts_object( design_template )
    image_settings = prompts[ PROMPTS_KEY_IMAGE_SETTINGS ][ image_name ]
    do_fit = image_settings[ PROMPTS_KEY_FIT_IMG ] if !image_settings.nil?
    Rails.logger.info 'versions_helper - resize_image_from_image_file() - do_fit: '\
      + do_fit.to_s

    return if do_fit != PROMPTS_VALUE_FIT_IMG_TRUE

    height = get_original_height( design_template, image_name )
    width = get_original_width( design_template, image_name )

    image = MiniMagick::Image.open( path )
    image = resize_with_crop( image, width.to_f, height.to_f )
    image.write( path )
  end





  def resize_with_crop(img, w, h, options = {})

    Rails.logger.info 'ImageHelper - resize_with_crop() - img: ' + img.to_s
    Rails.logger.info 'ImageHelper - resize_with_crop() - w: ' + w.to_s
    Rails.logger.info 'ImageHelper - resize_with_crop() - h: ' + h.to_s

    gravity = options[:gravity] || :center
    w_original, h_original = [img[:width].to_f, img[:height].to_f]

    op_resize = ''

    # check proportions
    if w_original * h < h_original * w
      op_resize = "#{w.to_i}x"
      w_result = w
      h_result = (h_original * w / w_original)
    else
      op_resize = "x#{h.to_i}"
      w_result = (w_original * h / h_original)
      h_result = h
    end

    w_offset, h_offset = crop_offsets_by_gravity(gravity, [w_result, h_result], [ w, h])

    img.combine_options do |i|
      i.resize(op_resize)
      i.gravity(gravity)
      i.crop "#{w.to_i}x#{h.to_i}+#{w_offset}+#{h_offset}!"
    end
    img
  end

  GRAVITY_TYPES = [ :north_west, :north, :north_east, :east, :south_east, :south, :south_west, :west, :center ]

  def crop_offsets_by_gravity(gravity, original_dimensions, cropped_dimensions)
    raise(ArgumentError, "Gravity must be one of #{GRAVITY_TYPES.inspect}") unless GRAVITY_TYPES.include?(gravity.to_sym)
    raise(ArgumentError, "Original dimensions must be supplied as a [ width, height ] array") unless original_dimensions.kind_of?(Enumerable) && original_dimensions.size == 2
    raise(ArgumentError, "Cropped dimensions must be supplied as a [ width, height ] array") unless cropped_dimensions.kind_of?(Enumerable) && cropped_dimensions.size == 2

    original_width, original_height = original_dimensions
    cropped_width, cropped_height = cropped_dimensions

    vertical_offset = case gravity
      when :north_west, :north, :north_east then 0
      when :center, :east, :west then [ ((original_height - cropped_height) / 2.0).to_i, 0 ].max
      when :south_west, :south, :south_east then (original_height - cropped_height).to_i
    end

    horizontal_offset = case gravity
      when :north_west, :west, :south_west then 0
      when :center, :north, :south then [ ((original_width - cropped_width) / 2.0).to_i, 0 ].max
      when :north_east, :east, :south_east then (original_width - cropped_width).to_i
    end

    return [ horizontal_offset, vertical_offset ]
  end

end

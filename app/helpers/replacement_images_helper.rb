# ReplacementImages Helper
module ReplacementImagesHelper
  include ApplicationHelper
  include ImageHelper


  # I use miniMagick to reformat the image because jpgs retrieved from
  # Instagram cause errors in AI.
  def crop_and_save_image( image, ri )

    design_template = ri.version.design_template
    image_name = ri.image_name
    path = ri.get_path

    height = get_original_height( design_template, image_name )
    width = get_original_width( design_template, image_name )

    image = resize_with_crop( image, width.to_f, height.to_f )

    image.format 'png'
    # Any name will do, the AI script will just place all of the images
    # found in the collage folder.
    full_path = path + '/image.png'
    image.write( full_path )
    return true
  end

  def fetch_image( ri )
    url = ri.url
    image = MiniMagick::Image.open( url )
    crop_and_save_image( image, ri )
    new_image_path = ri.get_path + 'image.png'
    ri.uploaded_file = File.new( new_image_path )
  end

end

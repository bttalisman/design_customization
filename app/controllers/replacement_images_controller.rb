class ReplacementImagesController < ApplicationController


  include ApplicationHelper


  def new
  end


  def create

    logger.info "REPLACEMENT_IMAGES_CONTROLLER - create!"

    version_id = params[ 'version_id' ]
    image_name = params[ 'image_name' ]

    version = Version.find( version_id )

    @replacement_image = version.replacement_images.create( replacement_image_params )

    logger.info "REPLACEMENT_IMAGES_CONTROLLER - version_id: " + version_id.to_s

#    @replacement_image = ReplacementImage.new( replacement_image_params )

    if @replacement_image.save
      logger.info "REPLACEMENT_IMAGES_CONTROLLER - replacement_image saved!"
    end

    # we've got to add this replacement image to the stored values of its version
    values = get_values_object( version )
    image_settings = values[ 'image_settings' ]

    if( !image_settings) then
      image_settings = {}
      values[ 'image_settings' ] = image_settings
    end

    settings = {}
    settings[ 'replacement_image_id' ] = @replacement_image.id
    image_settings[ image_name ] = settings
    
    version.values = values.to_json

    if version.save
      logger.info "REPLACEMENT_IMAGES_CONTROLLER - version saved!"
    end


    redirect_to action: 'edit', controller: 'versions', :id => version_id

  end






  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end


end

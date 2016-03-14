module VersionsHelper


  @@versions_folder = Rails.root.to_s + "/public/system/versions/"

  def get_version_folder( version )
    version_output_folder = @@versions_folder + version.id.to_s
    FileUtils.mkdir_p( version_output_folder ) unless File.directory?( version_output_folder )
    return version_output_folder
  end



  # A version's values is an object describing all extensible settings, set by the
  # user when creating a version
  def get_values_object( version )

    values_string = version.values

    #logger.info "APPLICATION_HELPER - get_values_object - values_string: " + values_string.to_s

    if( is_json?( values_string ) ) then
      values = JSON.parse values_string
    else
      logger.info "APPLICATION_HELPER - get_values_object - INVALID JSON!!"
    end

    values
  end


  def get_replacement_image_id( image_name, version )

    #logger.info "APPLICATION_HELPER - get_replacement_image_id!!"

    values = get_values_object( version )

    if( values != nil ) then
      image_values = values[ 'image_settings' ]
    end

    rep_id = ''

    if( image_values ) then
      vals = image_values[ image_name ]
      if( vals ) then
        rep_id = vals[ 'replacement_image_id' ]
      end
    end

    rep_id
  end

  def get_replacement_image( image_name, version )
    id = get_replacement_image_id( image_name, version )
    if( id != '' ) then
      ri = ReplacementImage.find( id )
    end
    ri
  end



  # A version associates image_names with actual uploaded files
  def get_uploaded_file( image_name, version )

    logger.info "APPLICATION_HELPER - get_uploaded_file !!"

    values = get_values_object( version )

    if( values != nil ) then
      image_values = values[ 'image_settings' ]
    end

    if( image_values ) then
      vals = image_values[ image_name ]
      if( vals ) then

        rep_id = vals[ 'replacement_image_id' ]

        if( rep_id ) then

          ri = ReplacementImage.find( rep_id )

        end
      end

    end

    if( ri ) then
      ri.uploaded_file
    end
  end



  def get_uploaded_file_name( image_name, version )

    uploaded_file = get_uploaded_file( image_name, version )

    if( uploaded_file ) then
      file_name = uploaded_file.original_filename
    end

    file_name
  end


  def get_local_image_path( image_name, version )

    uploaded_file = get_uploaded_file( image_name, version )

    if( uploaded_file ) then
      replacement_path = uploaded_file.path
    end

    replacement_path
  end



  def set_tag_values( version, params )

    logger.info "VERSIONS_HELPER - set_tag_values() - params: " + params.to_s

    version_data = JSON.parse( params[ 'version_data' ] )
    tag_settings =  version_data[ 'tag_settings' ]

    values = get_values_object( version )
    values[ 'tag_settings' ] = tag_settings

    version.values = values.to_json

    if version.save
      logger.info "VERSIONS_HELPER - set_tag_values() - version saved!"
    end

  end


  # a version's values object matches image tags to replacement_images.  this method
  # gets that version's values, and updates it with the id of the replacement_image, as well
  # as the path to the local file, as this is needed by the AI script.
  def add_replacement_image_to_version( ri, image_name, version )

    # todo, can this be part of a constructor?

    values = get_values_object( version )
    image_settings = values[ 'image_settings' ]

    settings = {}
    settings[ 'replacement_image_id' ] = ri.id
    settings[ 'path' ] = ri.uploaded_file.path

    image_settings[ image_name ] = settings

    logger.info "APPLICATION_HELPER - add_replacement_image_to_version() - values.to_json: " + values.to_json

    version.values = values.to_json

    if version.save
      logger.info "APPLICATION_HELPER - add_replacement_image_to_version() - version saved!"
    end

  end






end

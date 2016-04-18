# Versions Helper
module VersionsHelper
  @@versions_folder = Rails.root.to_s + '/public/system/versions/'

  def get_version_folder( version )
    logger.info 'VERSIONS_HELPER - get_version_folder() - @versions_folder: ' + @@versions_folder.to_s
    version_output_folder = @@versions_folder + version.id.to_s
    FileUtils.mkdir_p( version_output_folder )\
      unless File.directory?( version_output_folder )
    version_output_folder
  end

  # A version's values is an object describing all extensible settings,
  # set by the user when creating a version
  def get_values_object( version )
    values_string = version.values

    # logger.info 'APPLICATION_HELPER - get_values_object - values_string: '\
    # + values_string.to_s

    if json?( values_string )
      values = JSON.parse values_string
    else
      logger.info 'VERSIONS_HELPER - get_values_object - INVALID JSON!!'
    end

    values
  end

  def get_replacement_image_id( image_name, version )
    logger.info 'VERSIONS_HELPER - get_replacement_image_id()!!'

    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?
    rep_id = ''

    if image_values
      vals = image_values[ image_name ]
      rep_id = vals[ 'replacement_image_id' ] if vals
    end

    rep_id
  end

  def get_replacement_image( image_name, version )
    logger.info 'VERSIONS_HELPER - get_replacement_image()!!'
    id = get_replacement_image_id( image_name, version )
    ri = ReplacementImage.find( id ) if id != ''
    ri
  end

  # A version associates image_names with actual uploaded files
  def get_uploaded_file( image_name, version )
    logger.info 'VERSIONS_HELPER - get_uploaded_file !!'

    values = get_values_object( version )
    image_values = values[ 'image_settings' ] unless values.nil?

    if image_values
      vals = image_values[ image_name ]
      if vals
        rep_id = vals[ 'replacement_image_id' ]
        ri = ReplacementImage.find( rep_id ) if rep_id
      end
    end
    ri.uploaded_file if ri
  end

  def get_uploaded_file_name( image_name, version )
    uploaded_file = get_uploaded_file( image_name, version )
    file_name = uploaded_file.original_filename if uploaded_file
    file_name
  end

  def get_local_image_path( image_name, version )
    uploaded_file = get_uploaded_file( image_name, version )
    replacement_path = uploaded_file.path if uploaded_file
    replacement_path
  end

  def set_tag_values( version, params )
    logger.info 'VERSIONS_HELPER - set_tag_values() - params: ' + params.to_s

    version_data = JSON.parse( params[ 'version_data' ] )
    tag_settings = version_data[ 'tag_settings' ]

    values = get_values_object( version )
    values[ 'tag_settings' ] = tag_settings

    version.values = values.to_json

    logger.info 'VERSIONS_HELPER - set_tag_values() - version saved!'\
      if version.save
  end

  def set_image_values( version, params )
    design_template = version.design_template
    images = get_images_array( design_template )

    image_count = params[ 'image_count' ]

    image_count = if image_count != ''
                    image_count.to_i
                  else
                    0
                  end

    # get all of the uploaded files, for each create a ReplacementImage,
    # and bind it to the image_name
    image_count.times do |i|

      # params contain values keyed by:
      # => replacement_image<index>,
      # => image_name<index>,
      # => type<index>,
      # => query<index>
      # for each image.

      p_name = 'type' + i.to_s
      type = params[ p_name ]

      p_name = 'replacement_image' + i.to_s
      replacement_image = params[ p_name ]

      p_name = 'image_name' + i.to_s
      image_name = params[ p_name ]

      p_name = 'collage_query' + i.to_s
      query = params[ p_name ]

      logger.info 'VERSIONS_HELPER - set_image_values() - type: '\
        + type.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - image_name: '\
        + image_name.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - replacement_image: '\
        + replacement_image.to_s
      logger.info 'VERSIONS_HELPER - set_image_values() - query: '\
        + query.to_s

      if type == 'upload'
        if replacement_image
          my_file = replacement_image[ 'uploaded_file' ]
          logger.info 'VERSIONS_HELPER - set_image_values() - myFile: ' + my_file.to_s

          if my_file

            # get any replacement_image already associated with this image_name,
            # and destroy it.
            # No need to modify the version.values, we're just about to replace
            # that entry
            ri = get_replacement_image( image_name, version )
            logger.info 'VERSIONS_HELPER - set_image_values() - ri: ' + ri.to_s
            ri.destroy if ri

            o = { uploaded_file: my_file }
            @replacement_image = @version.replacement_images.create( o )
            @replacement_image.save

            # this will set version.values to reflect any user-set properties for
            # this version, these values will eventually be read by the AI script
            add_replacement_image_to_version( @replacement_image,\
                                              image_name, version )
          end # my_file
        end # replacement_image
      else
        # type = instagram
        logger.info 'VERSIONS_HELPER - set_image_values() - Instagram collage!'


      end
    end # image_count times
  end

  # a version's values object matches image tags to replacement_images.
  # this method gets that version's values, and updates it with the id of
  # the replacement_image, as well as the path to the local file,
  # as this is needed by the AI script.
  def add_replacement_image_to_version( ri, image_name, version )
    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'
    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version() - ri: '\
      + ri.to_s

    # todo, can this be part of a constructor?

    values = get_values_object( version )
    image_settings = values[ 'image_settings' ]

    settings = {}
    settings[ 'replacement_image_id' ] = ri.id
    settings[ 'path' ] = ri.uploaded_file.path

    image_settings[ image_name ] = settings

    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'\
      + ' - values.to_json: ' + values.to_json

    version.values = values.to_json

    logger.info 'VERSIONS_HELPER - add_replacement_image_to_version()'\
      + ' - version saved!' if version.save
  end
end

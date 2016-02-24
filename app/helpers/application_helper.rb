module ApplicationHelper


  @@versions_folder = Rails.root.to_s + "/public/system/versions/"


  def get_version_folder( version )

    version_output_folder = @@versions_folder + version.id.to_s
    FileUtils.mkdir_p( version_output_folder ) unless File.directory?( version_output_folder )

    return version_output_folder

  end



  def path_to_data_file( path_to_ai_file )

    source_folder = File.dirname( path_to_ai_file )
    base_name = File.basename( path_to_ai_file, '.ai' )

    data_file = source_folder + "/" + base_name +  "_data.jsn"

    data_file
  end



  # the path to the tags file is based on the path to the original ai file.
  def path_to_tags_file( design_template )

    file = design_template.original_file
    source_path = file.path.to_s

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_tags.jsn"

    data_file
  end


  # the path to the images file is based on the path to the original ai file.
  def path_to_images_file( design_template )

    file = design_template.original_file
    source_path = file.path.to_s

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_images.jsn"

    data_file
  end




  def tags_file_exist?( design_template )
    path = path_to_tags_file( design_template )
    exists = File.exist?( path )
    exists
  end



  # This method assumes that there is a file cotaining a json array of the names
  # of all tags extracted from the DesignTemplate's associated AI file.
  def get_tags_array( design_template )

    tags_file = path_to_tags_file( design_template )
    exists = File.exist?( tags_file )

    logger.info "APPLICATION_HELPER - get_tags_array - exists: " + exists.to_s

    tags_string = ''
    tags = nil

    if exists then
      File.open( tags_file,"r" ) do |f|
        tags_string = f.read()
      end
      tags = JSON.parse( tags_string )
    end

    tags

  end


  # This method assumes that there is a file cotaining a json array of the names
  # of all images extracted from the DesignTemplate's associated AI file.
  def get_images_array( design_template )

    images_file = path_to_images_file( design_template )
    exists = File.exist?( images_file )

    logger.info "APPLICATION_HELPER - get_images_array - exists: " + exists.to_s

    images_string = ''
    images = nil

    if exists then
      File.open( images_file,"r" ) do |f|
        images_string = f.read()
      end
      images = JSON.parse( images_string )
    end

    images

  end


  def get_values_object( version )

    values_string = version.values
    logger.info "APPLICATION_HELPER - get_values_object - values_string: " + values_string.to_s

    if( values_string != nil ) then
      if( values_string != '' ) then
        values = JSON.parse values_string
      end
    end

    values
  end


  def get_prompts_object( design_template )

      prompts_string = design_template.prompts
      prompts = JSON.parse( prompts_string )

      logger.info "APPLICATION_HELPER - get_prompts_object - prompts_string: " + prompts_string.to_s
      logger.info "APPLICATION_HELPER - get_prompts_object - prompts: " + prompts.to_s

      prompts
  end




end

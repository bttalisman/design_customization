# DesignTemplates Helper
module DesignTemplatesHelper
  # the path to the tags file is based on the path to the original ai file.
  def path_to_tags_file( design_template )
    file = design_template.original_file
    source_path = file.path.to_s
    source_folder = File.dirname( source_path )
    data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
      + '_tags.jsn'
    data_file
  end

  # the path to the images file is based on the path to the original ai file.
  def path_to_images_file( design_template )
    file = design_template.original_file
    source_path = file.path.to_s
    source_folder = File.dirname( source_path )
    data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
      + '_images.jsn'
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

    # logger.info 'APPLICATION_HELPER - get_tags_array - exists: ' + exists.to_s

    tags_string = ''
    tags = []

    if exists
      File.open( tags_file, 'r' ) do |f|
        tags_string = f.read
      end

      tags = JSON.parse( tags_string ) if json?( tags_string )
    end

    tags
  end

  def tags?( design_template )
    a = get_tags_array( design_template )
    return false if a.empty?
    true
  end

  def images?( design_template )
    a = get_images_array( design_template )
    return false if a.empty?
    true
  end

  # This method assumes that there is a file containing a json array of the
  # names of all images extracted from the DesignTemplate's associated AI file.
  def get_images_array( design_template )
    # logger.info 'APPLICATION_HELPER - get_images_array()'
    images_file = path_to_images_file( design_template )
    # logger.info 'APPLICATION_HELPER - get_images_array() - images_file: '\
    # + images_file.to_s

    exists = File.exist?( images_file )

    # logger.info 'APPLICATION_HELPER - get_images_array - exists: '\
    # + exists.to_s

    images_string = ''
    images = []

    if exists
      File.open( images_file, 'r' ) do |f|
        images_string = f.read
      end
      images = JSON.parse( images_string ) if json?( images_string )
    end

    images
  end

  # a design_template's prompts object describes any extensible settings
  # presented by versions of this template, such as replace this image?, allow
  # users to set the color of this text?
  def get_prompts_object( design_template )
    prompts_string = design_template.prompts

    prompts = JSON.parse( prompts_string ) if json?( prompts_string )

    # logger.info 'APPLICATION_HELPER - get_prompts_object - prompts_string: '\
    # + prompts_string.to_s
    # logger.info 'APPLICATION_HELPER - get_prompts_object - prompts: '\
    # + prompts.to_s

    prompts
  end
end

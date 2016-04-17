# Versions Controller
class VersionsController < ApplicationController
  include ApplicationHelper
  include VersionsHelper
  include DesignTemplatesHelper

  @@path_to_runner_script = Rails.root.to_s\
    + '/bin/illustrator_processing/run_AI_script.rb'
  @@path_to_extract_tags_script = Rails.root.to_s\
    + '/bin/illustrator_processing/extractTags.jsx'
  @@path_to_extract_images_script = Rails.root.to_s\
    + '/bin/illustrator_processing/extractImages.jsx'
  @@path_to_search_replace_script = Rails.root.to_s\
    + '/bin/illustrator_processing/searchAndReplace.jsx'
  @@path_to_image_search_replace_script = Rails.root.to_s\
    + '/bin/illustrator_processing/searchAndReplaceImages.jsx'
  @@path_to_quick_version_root = Rails.root.to_s + '/versions'

  def delete_all
    logger.info 'VERSIONS_CONTROLLER - delete_all'

    versions = Version.all
    versions.each( &:delete )

    render nothing: true
  end

  def index
    versions = Version.all
    @versions = []

    versions.each do |v|
      o = { name: v.name.to_s,
            template: v.design_template.name.to_s,
            tags: bool_display_text( tags?( v.design_template ) ),
            images: bool_display_text( images?( v.design_template ) ),
            id: v.id.to_s,
            template_id: v.design_template.id.to_s,
            created: time_display_text( v.created_at )
      }
      @versions << o
    end
  end

  def edit
    @version = Version.find( params[ :id ] )
    @design_template = @version.design_template

    if @design_template.nil?
      redirect_to versions_path
      return
    end

    @design_templates = DesignTemplate.all
    @design_template_id = @design_template.id
    @values = get_values_object( @version )
    @root_folder = Rails.root.to_s
  end

  def update
    logger.info ''
    logger.info ''
    logger.info 'VERSION_COTROLLER - UPDATE'
    logger.info 'VERSION_COTROLLER - UPDATE - version_params: '\
      + version_params.to_s

    @version = Version.find( params[ :id ] )
    # this takes care of name, output folder, etc.
    @version.update( version_params )

    # extract the tag-related settings from the parameters object, and set
    # this version's values property.  This is done independently of
    # image-related settings.
    set_tag_values( @version, params )

    set_image_values( @version, params )

    @design_template = @version.design_template
    # this is an array of tag names, extracted from the AI file
    @tags = get_tags_array( @design_template )
    # this is an array of image names, extracted from the AI file
    @images = get_images_array( @design_template )

    process_version if @version.save
    redirect_to versions_path
  end

  def new
    logger.info 'VERSIONS_CONTROLLER - NEW'
    @version = Version.new
    @design_templates = DesignTemplate.all
    @root_folder = Rails.root.to_s
  end

  def quick_new
    logger.info 'VERSIONS_CONTROLLER - QUICK_NEW'
    template_id = params[ :template_id ]
    @design_template = DesignTemplate.find( template_id )

    config_hash = { design_template_id: template_id }

    @version = Version.new( config_hash )
    @version.save

    version_folder_path = @@path_to_quick_version_root + '/template_'\
      + @design_template.id.to_s + '/version_' + @version.id.to_s + '/'
    version_name = @design_template.name + '_' + @version.id.to_s

    @version.name = version_name
    @version.output_folder_path = version_folder_path
    @version.save
  end

  def create
    logger.info 'VERSIONS_CONTROLLER - CREATE'
    @version = Version.new( version_params )

    if @version.save
      redirect_to action: 'edit', id: @version.id
    else
      logger.info 'VERSION_CONTROLLER - create - FAILURE!'
      render 'new'
    end
  end

  def show
    @version = Version.find( params[ :id ] )
    @design_template = @version.design_template
    @root_folder = Rails.root.to_s
    @replacement_images = @version.replacement_images

    @version_folder = get_version_folder( @version )

    if !@design_template.nil?
      @data_file = path_to_data_file( @version.design_template.original_file.path )
    end

    logger.info 'version_controller - show - @version: ' + @version.to_s
    logger.info 'version_controller - show - @design_template: '\
      + @design_template.to_s
    logger.info 'version_controller - show - @replacement_images: '\
      + @replacement_images.to_s
    logger.info 'version_controller - show - @replacement_images.length: '\
      + @replacement_images.length.to_s

    @design_template = DesignTemplate.new if @design_template.nil?
  end

  def destroy
    logger.info 'VERSIONS_CONTROLLER - destroy'
    @version = Version.find( params[ :id ] )
    @version.destroy
    redirect_to :versions
  end

  # whenever a user visits the new version page, a new Version must be created
  # so that uploaded files can be attached.  if user clicks cancel, we've got to
  # delete the version created.
  def cancel
    logger.info 'VERSIONS_CONTROLLER - cancel'
    version = Version.find( params[ :id ] )
    version.destroy
    redirect_to :versions
  end

  private

  def version_params
    # params.require(:version).permit( :output_folder_path, :values, :name,
    # :design_template_id )
    params.require(:version).permit!
  end

  # This method writes the current version's values string to a file sitting
  # right next to an AI file, named with _data.jsn.
  def write_temp_data_file( path_to_ai_file )
    logger.info 'VERSIONS_CONTROLLER - write_temp_data_file - path_to_ai_file: '\
      + path_to_ai_file.to_s
    temp_values_file = path_to_data_file( path_to_ai_file )

    # we'll create a temporary file containing necessary info, sitting right
    # next to the original ai file.
    File.open( temp_values_file, 'w' ) do |f|
      f.write( @version.values.to_s )
    end
  end

  def do_run_ai( config )
    logger.info 'VERSIONS_CONTROLLER - run_ai - config: ' + config.to_s

    # this will put an appropriately named data file right next to the
    # source file
    write_temp_data_file( config['source file'] )

    # create a config file that tells run_AI_script what it needs.  This file
    # can be anywhere, but we'll put it in the version folder
    version_output_folder = get_version_folder( @version )
    config_file = version_output_folder + '/config_ai.jsn'
    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    # And run it!

    sys_com = 'ruby ' + @@path_to_runner_script + ' "' + config_file + '"'
    logger.info 'VERSIONS_CONTROLLER - run_ai - about to run sys_com: '\
      + sys_com.to_s
    # run the ruby script. AI should generate output files to the output folder
    system( sys_com )
  end

  def process_version
    runai = params['runai']
    logger.info 'VERSIONS_CONTROLLER - process_version - runai: ' + runai.to_s

    # bail out for any of these reasons
    if @version.design_template.nil?
      logger.info 'VERSIONS_CONTROLLER - process_version - '\
        + 'NOT PROCESSING, no template.'
      return
    end
    if runai != 'true'
      logger.info 'VERSIONS_CONTROLLER - process_version - '\
        + 'NOT PROCESSING, runai not on.'
      return
    end
    if @images.empty? && @tags.empty?
      logger.info 'VERSIONS_CONTROLLER - process_version - '\
        + 'NOT PROCESSING, no images and no tags.'
      return
    end

    original_file = @version.design_template.original_file
    original_file_path = original_file.path
    original_file_name = File.basename( original_file_path )
    original_file_base_name = File.basename( original_file_path, '.ai' )

    version_folder = get_version_folder( @version )
    version_file_path = version_folder + '/' + original_file_name

    # copy the original file to the version folder, same name
    logger.info 'VERSIONS_CONTROLLER - process_version - '\
      + 'about to copy original file.'
    FileUtils.cp( original_file_path, version_file_path )

    if @version.output_folder_path != ''
      # the user has specified an output folder
      logger.info 'VERSIONS_CONTROLLER - process_version - '\
        + 'user specified output folder.'
      output_folder = guarantee_final_slash( @version.output_folder_path )
    else
      # the user has not specified an output folder,
      # we'll just use the version folder
      logger.info 'VERSIONS_CONTROLLER - process_version - '\
        + 'NO user specified output folder.'
      output_folder = guarantee_final_slash( version_folder )
    end

    logger.info 'VERSIONS_CONTROLLER - process_version - output_folder: '\
      + output_folder.to_s
    logger.info 'VERSIONS_CONTROLLER - process_version - '\
      + 'original_file_base_name: ' + original_file_base_name.to_s
    intermediate_output = output_folder.to_s + original_file_base_name.to_s\
      + '_mod.ai'
    logger.info 'VERSIONS_CONTROLLER - process_version - intermediate_output: '\
      + intermediate_output.to_s

    int_file_exist = false

    if !@tags.empty?
      # There are tags to replace, we should replace tags

      config = {}
      config[ 'source file' ] = version_file_path
      config[ 'script file' ] = @@path_to_search_replace_script
      config[ 'output folder' ] = output_folder

      do_run_ai( config )

      # unless something went wrong, this should exist
      int_file_exist = File.exist?( intermediate_output )
      logger.info 'VERSIONS_CONTROLLER - process_version - int_file_exist: '\
        + int_file_exist.to_s

    end # there are tags to replace

    if !@images.empty?
      # There are images to replace, we should replace images

      config = {}
      if int_file_exist
        config[ 'source file' ] = intermediate_output
      else
        # the intermediate file does not exist, but we should still
        # replace images
        config[ 'source file' ] = version_file_path
      end
      config[ 'script file' ] = @@path_to_image_search_replace_script
      config[ 'output folder' ] = output_folder

      do_run_ai( config )

    end # there are images to replace
  end
end

# Versions Controller
class VersionsController < ApplicationController
  include ApplicationHelper
  include VersionsHelper
  include DesignTemplatesHelper

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
      next if !v.design_template
      o = { name: v.name.to_s,
            template: v.design_template.name.to_s,
            tags: bool_display_text( tags?( v.design_template ) ),
            images: bool_display_text( images?( v.design_template ) ),
            id: v.id.to_s,
            template_id: v.design_template.id.to_s,
            created: time_display_text( v.created_at ),
            updated: time_display_text( v.updated_at ) }
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
    # this version's values property.
    set_tag_values( @version, params )
    # extract the image-related settings from the parameters object, and set
    # this version's values property.  This method also creates the
    # replacement_image objects that make up the version.replacement_images
    # collection.
    set_image_values( @version, params )

    # do anything that needs to be done to replacement_images.  The version's
    # replacement_images collection is created by the set_image_values method
    # above.
    process_replacement_images( @version )

    process_version( @version, params ) if @version.save
    redirect_to versions_path
  end

  def new
    logger.info 'VERSIONS_CONTROLLER - NEW'
    @version = Version.new
    @design_templates = DesignTemplate.all
    @root_folder = Rails.root.to_s
  end

  def quick_new
    app_config = Rails.application.config_for(:customization)
    logger.info 'VERSIONS_CONTROLLER - QUICK_NEW'
    template_id = params[ :template_id ]
    @design_template = DesignTemplate.find( template_id )

    config_hash = { design_template_id: template_id }

    @version = Version.new( config_hash )
    @version.save

    version_folder_path = app_config[ 'path_to_quick_version_root' ] + '/template_'\
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
      @data_file = path_to_data_file( @version.design_template.original_file.path.to_s )
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
    params.require(:version).permit( :output_folder_path, :values, :name, :design_template_id )
    # sparams.require(:version).permit!
  end

end

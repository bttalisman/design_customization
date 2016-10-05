# Versions Controller
class VersionsController < ApplicationController
  include ApplicationHelper
  include VersionsHelper
  include DesignTemplatesHelper
  include UsersHelper

  def delete_all
    logger.info 'VERSIONS_CONTROLLER - delete_all'
    versions = Version.all
    versions.each( &:delete )
    render nothing: true
  end

  def index
    user = get_logged_in_user

    if is_super_user || user.nil?
      versions = Version.all
    else
      user_id = user.id
      versions = Version.where( user_id: user_id )
    end

    @versions = []

    if versions
      versions.each do |v|
        next if !v.design_template
        o = { name: v.name.to_s,
              template: v.design_template.name.to_s,
              tags: bool_display_text( tags?( v.design_template ) ),
              images: bool_display_text( images?( v.design_template ) ),
              id: v.id.to_s,
              template_id: v.design_template.id.to_s,
              created: time_display_text( v.created_at ),
              updated: time_display_text( v.updated_at ),
              owner: get_full_name( v.user_id ),
              last_render_date: time_display_text( v.last_render_date )
            }
        @versions << o
      end
    end

#    logger.info 'VERSIONS_CONTROLLER - index() - @versions: '\
#      + JSON.pretty_generate( @versions )
  end

  def edit
    logger.info ''
    logger.info ''
    logger.info 'VERSION_COTROLLER - EDIT'
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

    # extract trans-butt related settings and add these values to version.values
    set_trans_butt_values( @version, params )


    set_color_values( @version, params )

    # do anything that needs to be done to replacement_images.  The version's
    # replacement_images collection is created by the set_image_values method
    # above.
    process_replacement_images( @version )

    process_version( @version, params ) if @version.save
    send_to_render( @version, params )

    redirect_to versions_path
  end

  def new
    logger.info 'VERSIONS_CONTROLLER - NEW'
    @version = Version.new
    @design_templates = DesignTemplate.all
  end

  def update_render_folder
    @version = Version.find( params[ :id ] )
    update_local_render_folder( @version )
    render nothing: true
  end

  # The real action behind this action is controlled by the partials controller.
  # This action uses the application layout, which includes all js libraries,
  # the partials#quick_new action generates all the html.
  def quick_new
    logger.info 'VERSIONS_CONTROLLER - QUICK_NEW'
    @template_id = params[ :template_id ]

    user = get_logged_in_user
    @user_id = user.id if !user.nil?
  end

  def create
    logger.info 'VERSIONS_CONTROLLER - CREATE'
    @version = Version.new( version_params )

    user = get_logged_in_user
    @version.update( { user_id: user.id } ) if user

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

    @render_url = get_render_url( @version, false )
    @render_image_url = get_render_image_url( @version, false )
    @render_image_count = get_local_render_image_count( @version, false )

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

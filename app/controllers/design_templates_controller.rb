# Controller for DesignTemplates
class DesignTemplatesController < ApplicationController
  include ApplicationHelper
  include DesignTemplatesHelper
  include UsersHelper

  def index
    user = get_logged_in_user

    if user
      user_id = user.id
      templates = DesignTemplate.where( user_id: user_id )
    else
      templates = DesignTemplate.all
    end

    @design_templates = []
    templates.each do |t|
      o = { name: t.name.to_s,
            tags: bool_display_text( tags?(t) ),
            images: bool_display_text( images?(t) ),
            id: t.id.to_s,
            created: time_display_text( t.created_at ),
            updated: time_display_text( t.updated_at ),
            owner: get_full_name( t.user_id ) }
      @design_templates << o
    end

    Rails.logger.info 'design_templates_controller - index() - @design_templates: '\
      + JSON.pretty_generate( @design_templates )
  end

  def show
    @design_template = DesignTemplate.find( params[ :id ] )
    @versions = @design_template.versions
    # this stats object describes the state and validity of the template
    @stats = get_stats( @design_template )

    file = @design_template.original_file
    unless file.path.nil?
      source_path = file.path
      @folder = File.dirname( source_path.to_s )
    end

    @quick_new_partial_url = local_host + '/partials/quick_new?template_id='\
                              + @design_template.id.to_s + '&user_id=<SHOPIFY_USER_ID>'
  end

  def edit
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - edit! - params: ' + params.to_s
    @design_template = DesignTemplate.find( params[ :id ] )

    # this stats object describes the state and validity of the template
    @stats = get_stats( @design_template )
    # this is an array of tag names, extracted from the AI file
    @tags = get_tags_array( @design_template )
    # this is an array of image names, extracted from the AI file
    @images = get_images_array( @design_template )

    @managed_asset = ManagedAsset.new
    @managed_assets = ManagedAsset.all
    @asset_prefs = get_asset_prefs_object( @design_template )
  end

  def update
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - update! - params: ' + params.to_s
    @design_template = DesignTemplate.find( params[ :id ] )
    @design_template.update( design_template_params )

#    set_assets( @design_template, params )

    # extract the tag-related settings from the parameters object, and set
    # this template's prompts property.
    set_tag_prompts( @design_template, params )
    # extract the image-related settings from the parameters object, and set
    # this template's prompts property.
    set_image_prompts( @design_template, params )
    # extract trans-butt-related settings from the parameters object, and
    # set prompts.
    set_trans_butt_prompts( @design_template, params )

    if @design_template.save
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - update - SUCCESS!'

      # Do any post-processing necessary.  Original purpose: to fix paths to
      # missing files.
      post_process( @design_template )

      redirect_to design_template_path
    else
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - update - FAILURE!'
      render 'new'
    end
  end

  def new
    @design_template = DesignTemplate.new
  end

  def create
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - create()!'
    @design_template = DesignTemplate.new( design_template_params )

    user = get_logged_in_user
    @design_template.update( { user_id: user.id } ) if user

    stay_after_save = params[ 'stayAfterSave' ]
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - create() - design_template_params: '\
    + design_template_params.to_s
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - create() - stay_after_save: '\
    + stay_after_save

    if @design_template.save
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - create() - SUCCESS! About to'\
      + ' process the AI file.'
      process_original( @design_template )

      if stay_after_save == 'true'
        # This action was called because the user wants to edit the extracted
        # settings. We've got to save and process first.
        redirect_to action: 'edit', id: @design_template.id
      else
        redirect_to design_templates_path
      end
    else
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - create() - FAILURE!'
      render 'new'
    end
  end

  def force_process
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - force_process()'
    @design_template = DesignTemplate.find( params[ :id ] )
    process_original( @design_template )
    redirect_to @design_template
  end

  def delete_all
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - delete_all()'

    assets = ManagedAsset.all
    assets.each( &:delete )

    dts = DesignTemplate.all
    dts.each( &:delete )
    render nothing: true
  end

  def destroy
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - destroy()'
    @design_template = DesignTemplate.find( params[ :id ] )
    @design_template.destroy
    redirect_to :design_templates
  end

  def remove_all_managed_assets
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - remove_all_managed_assets()'
    @design_template = DesignTemplate.find( params[ :id ] )
    @design_template.managed_assets.clear
#    assets = @design_template.managed_assets.all
#    assets.each( &:delete )
    render nothing: true
  end



  def add_managed_asset
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - add_managed_asset()'
    design_template = DesignTemplate.find( params[ :id ] )
    asset = ManagedAsset.find( params[ :managed_asset_id ] )
    add_managed_asset_and_process_prefs( design_template, asset )
    render nothing: true
  end

  def remove_managed_asset
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - remove_managed_asset()'
    design_template = DesignTemplate.find( params[ :id ] )
    asset = ManagedAsset.find( params[ :managed_asset_id ] )
    remove_managed_asset_and_process_prefs( design_template, asset )
    render nothing: true
  end


  def move_asset_up
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - move_asset_up()'
    design_template = DesignTemplate.find( params[ :id ] )
    asset = ManagedAsset.find( params[ :managed_asset_id ] )


    render nothing: true
  end

  def move_asset_down
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - move_asset_down()'
    design_template = DesignTemplate.find( params[ :id ] )
    asset = ManagedAsset.find( params[ :managed_asset_id ] )
    remove_managed_asset_and_process_prefs( design_template, asset )
    render nothing: true
  end


  # This action makes a design_template with no Illustrator file associated.
  # tags and images json files are created, and the template should function
  # normally.
  def make_zombie
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - make_zombie()'
    build_zombie_template
    render 'home/tools'
  end

  private

  def design_template_params
    params.require( :design_template )\
          .permit( :orig_file_path, :name, :tags, :original_file, :is_trans_butt )
  end
end

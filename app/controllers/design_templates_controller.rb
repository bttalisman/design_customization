# Controller for DesignTemplates
class DesignTemplatesController < ApplicationController
  include ApplicationHelper
  include DesignTemplatesHelper

  def index
    templates = DesignTemplate.all
    @design_templates = []

    templates.each do |t|
      o = { name: t.name.to_s,
            tags: bool_display_text( tags?(t) ),
            images: bool_display_text( images?(t) ),
            id: t.id.to_s,
            created: time_display_text( t.created_at ),
            updated: time_display_text( t.updated_at ) }
      @design_templates << o
    end
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
                              + @design_template.id.to_s
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
  end

  def update
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - update! - params: ' + params.to_s

    @design_template = DesignTemplate.find( params[ :id ] )
    @design_template.update( design_template_params )

    logger.info 'DESIGN_TEMPLATES_CONTROLLER - update - about to save.'
    if @design_template.save
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - update - SUCCESS!'
      redirect_to design_template_path
    else
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - update - FAILURE!'
      render 'new'
    end
  end

  # this action executes in response to an ajax call from the Design Template
  # editor, the body of the post made contains JSON describing all extensible
  # settings
  def all_settings
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings()'

    # expecting something like { 'extracted_settings' => arbitrary settings
    # depending on tags, 'general_settings' => settings every DesignTemplate has
    my_hash_string = request.body.read.to_s
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - body: ' \
     + my_hash_string

    if json?( my_hash_string )
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - good JSON!'
      my_hash = JSON.parse my_hash_string
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - my_hash: ' \
       + JSON.pretty_generate( my_hash )
    else
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - BAD JSON!'
    end

    extracted_object = my_hash[ 'extracted_settings' ]
    extracted_string = extracted_object.to_json

    logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - setting prompts to: '\
      + extracted_string.to_s
    @design_template = DesignTemplate.find( params[ :id ] )
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - @design_template.name: '\
      + @design_template.name.to_s
    @design_template.prompts = extracted_string

    @design_template.name = my_hash[ 'general_settings' ][ 'template_name' ]

    if @design_template.save
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - save SUCCESS!'
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - @design_template.name: '\
        + @design_template.name.to_s
    else
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - all_settings() - save FAILURE!'
    end

    render nothing: true
  end

  def new
    @design_template = DesignTemplate.new
  end

  def create
    logger.info 'DESIGN_TEMPLATES_CONTROLLER - create()!'
    @design_template = DesignTemplate.new( design_template_params )

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
          .permit( :orig_file_path, :name, :tags, :original_file )
  end
end

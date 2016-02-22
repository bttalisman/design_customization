class PartialsController < ApplicationController

  include ApplicationHelper

  layout 'partials'


  # This action presents the tags extracted from the AI file, with any
  # tag-specific options, for use when creating or editing a DesignTemplate
  def tags

    template_id = params[ :id ]
    @design_template = DesignTemplate.find( template_id )
    @tags = get_tags_array( @design_template )

    # If the user has set options regarding tags extracted from an AI file they
    # go in @values
    if ( @design_template.prompts != nil ) then
      @values = JSON.parse( @design_template.prompts )
    end

    logger.info "PARTIALS_CONTROLLER - tags - template_id: " + template_id.to_s
    logger.info "PARTIALS_CONTROLLER - tags - @tags: " + @tags.to_s
    logger.info "PARTIALS_CONTROLLER - tags - @values: " + @values.to_s

  end



  # This action presents each tag with ui for setting version-specific options
  # for use in creating a Version tied to a DesignTemplate
  def values

    id = params[ :id ]
    logger.info "PARTIALS_CONTROLLER - values - id: " + id.to_s

    version_id = params[ :version_id ]
    logger.info "PARTIALS_CONTROLLER - values - version_id: " + version_id.to_s


    @design_template = DesignTemplate.find( id )

    if( version_id != nil ) then
      version = Version.find( version_id )
    end

    if( version != nil ) then
      @values = get_values_object( version )
    end

    @prompts = get_prompts_object( @design_template )
  
  end

end

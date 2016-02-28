class PartialsController < ApplicationController

  include ApplicationHelper

  layout 'partials'


  # This action presents the tags extracted from the AI file, with any
  # tag-specific options, for use when creating or editing a DesignTemplate
  def design_template_settings

    template_id = params[ :id ]
    @design_template = DesignTemplate.find( template_id )
    @tags = get_tags_array( @design_template )
    @images = get_images_array( @design_template )

    # If the user has set options regarding tags extracted from an AI file they
    # go in @values
    if( is_json?( @design_template.prompts ) ) then
      @values = JSON.parse( @design_template.prompts )
    else
      logger.info "PARTIALS_CONTROLLER - extracted_settings - BAD json!!!"
    end

    logger.info "PARTIALS_CONTROLLER - design_template_settings - template_id: " + template_id.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @tags: " + @tags.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @images: " + @images.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @values: " + @values.to_s

  end



  # This action presents each tag with ui for setting version-specific options
  # for use in creating a Version tied to a DesignTemplate
  def version_settings

    id = params[ :id ]
    logger.info "PARTIALS_CONTROLLER - version_settings - id: " + id.to_s

    version_id = params[ :version_id ]
    logger.info "PARTIALS_CONTROLLER - version_settings - version_id: " + version_id.to_s


    @design_template = DesignTemplate.find( id )

    if( version_id != nil ) then
      version = Version.find( version_id )
    end

    if( version != nil ) then
      values = get_values_object( version )

      if( values != nil ) then
        @image_values = values[ 'image_settings' ]
        @tag_values = values[ 'tag_settings' ]
      end

    end

    @prompts = get_prompts_object( @design_template )

  end

end

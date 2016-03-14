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
      logger.info "PARTIALS_CONTROLLER - design_template_settings - BAD json!!!"
    end

    logger.info "PARTIALS_CONTROLLER - design_template_settings - template_id: " + template_id.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @tags: " + @tags.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @images: " + @images.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @values: " + @values.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @images.length: " + @images.length.to_s
    logger.info "PARTIALS_CONTROLLER - design_template_settings - @tags.length: " + @tags.length.to_s


  end



  # This action presents each tag with ui for setting version-specific options
  # for use in creating a Version tied to a DesignTemplate.  It is called whenever
  # the user changes the DesignTemplate associated with this version.
  def version_settings

    id = params[ :id ]
    logger.info "PARTIALS_CONTROLLER - version_settings - id: " + id.to_s

    @version_id = params[ :version_id ]
    logger.info "PARTIALS_CONTROLLER - version_settings - @version_id: " + @version_id.to_s


    @design_template = DesignTemplate.find( id )
    @tags = get_tags_array( @design_template )
    @images = get_images_array( @design_template )


    logger.info "PARTIALS_CONTROLLER - version_settings - @tags: " + @tags.to_s
    logger.info "PARTIALS_CONTROLLER - version_settings - @images: " + @images.to_s
    logger.info "PARTIALS_CONTROLLER - version_settings - @images.length: " + @images.length.to_s
    logger.info "PARTIALS_CONTROLLER - version_settings - @tags.length: " + @tags.length.to_s


    if( @version_id != nil ) then
      @version = Version.find( @version_id )
    else
      @version_id = '' # if it's nil, make it '' so we can just use it without thinking
    end

    logger.info "PARTIALS_CONTROLLER - version_settings - @version: " + @version.to_s

    if( @version != nil ) then

      # we've got to update this version to reflect the new DesignTemplate, and we've got to
      # do this because the version has to be saved and ready if the user tries to attach
      # a file to it.
      o = { 'design_template_id' => @design_template.id.to_s }
      @version.update( o )

      if @version.save
        logger.info "PARTIALS_CONTROLLER - version_settings - VERSION SAVED!"
      else
        logger.info "PARTIALS_CONTROLLER - version_settings - VERSION NOT SAVED!"
      end

      values = get_values_object( @version )

      if( values != nil ) then
        @image_values = values[ 'image_settings' ]
        @tag_values = values[ 'tag_settings' ]
      end

    end

    @prompts = get_prompts_object( @design_template )

  end

end

# Partials Controller
class PartialsController < ApplicationController
  include ApplicationHelper
  include DesignTemplatesHelper
  include VersionsHelper

  layout 'partials'

  @@path_to_quick_version_root = Rails.root.to_s + '/versions'

  # This action presents the tags extracted from the AI file, with any
  # tag-specific options, for use when creating or editing a DesignTemplate
  def design_template_settings
    template_id = params[ :id ]
    @design_template = DesignTemplate.find( template_id )
    @tags = get_tags_array( @design_template )
    @images = get_images_array( @design_template )
    @palettes = Palette.all

    # If the user has set options regarding tags extracted from an AI file they
    # go in @values
    if json?( @design_template.prompts )
      @values = JSON.parse( @design_template.prompts )
    else
      logger.info 'PARTIALS_CONTROLLER - design_template_settings - BAD json!!!'
    end

    logger.info 'PARTIALS_CONTROLLER - design_template_settings - template_id: '\
      + template_id.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @tags: '\
      + @tags.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @images: '\
      + @images.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @values: '\
      + @values.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @images.length: '\
      + @images.length.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @tags.length: '\
      + @tags.length.to_s
  end

  def quick_new
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

  def get_palettes( template )
    palettes = {}
    prompts = get_prompts_object( template )
    tag_settings = prompts[ 'tag_settings' ]

    tag_settings.each do |t|
      use_palette = t[ 1 ][ 'use_palette' ]
      palette_id = t[ 1 ][ 'palette_id' ]

      logger.info 'PARTIALS_CONTROLLER - get_palettes - t: ' + t.to_s
      logger.info 'PARTIALS_CONTROLLER - get_palettes - use_palette: '\
        + use_palette.to_s

      if use_palette == 'checked'

        begin
          palette = Palette.find( palette_id )
          palettes[ t[0] ] = palette.colors

        rescue ActiveRecord::RecordNotFound
          palettes[ t[0] ] = Color.all
        end

      else
        palettes[ t[0] ] = Color.all
      end
    end

    logger.info 'PARTIALS_CONTROLLER - get_palettes - palettes: '\
      + palettes.to_s

    palettes
  end

  # This action presents each tag with ui for setting version-specific options
  # for use in creating a Version tied to a DesignTemplate.  It is called
  # whenever the user changes the DesignTemplate associated with this version.
  def version_settings
    id = params[ :id ]
    logger.info 'PARTIALS_CONTROLLER - version_settings - id: ' + id.to_s

    @version_id = params[ :version_id ]
    logger.info 'PARTIALS_CONTROLLER - version_settings - @version_id: '\
      + @version_id.to_s

    @design_template = DesignTemplate.find( id )
    @tags = get_tags_array( @design_template )
    @images = get_images_array( @design_template )
    @colors = Color.all
    @palettes = get_palettes( @design_template )

    logger.info 'PARTIALS_CONTROLLER - version_settings - @tags: ' + @tags.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings - @images: '\
      + @images.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings - @images.length: '\
      + @images.length.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings - @tags.length: '\
      + @tags.length.to_s

    if !@version_id.nil?
      @version = Version.find( @version_id )
    else
      # if it's nil, make it '' so we can just use it without thinking
      @version_id = ''
    end

    logger.info 'PARTIALS_CONTROLLER - version_settings - @version: '\
      + @version.to_s

    if !@version.nil?

      # we've got to update this version to reflect the new DesignTemplate,
      # and we've got to do this because the version has to be saved and ready
      # if the user tries to attach a file to it.
      o = { 'design_template_id' => @design_template.id.to_s }
      @version.update( o )

      if @version.save
        logger.info 'PARTIALS_CONTROLLER - version_settings - VERSION SAVED!'
      else
        logger.info 'PARTIALS_CONTROLLER - version_settings - VERSION NOT SAVED!'
      end

      values = get_values_object( @version )

      if !values.nil?
        @image_values = values[ 'image_settings' ]
        @tag_values = values[ 'tag_settings' ]
      end

    end

    @prompts = get_prompts_object( @design_template )
  end
end

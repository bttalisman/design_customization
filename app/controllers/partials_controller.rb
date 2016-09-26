# Partials Controller
class PartialsController < ApplicationController
  include ApplicationHelper
  include DesignTemplatesHelper
  include VersionsHelper
  include PartialsHelper
  include ManagedAssetsHelper

  layout 'partials'

  def _managed_assets
    logger.info 'PARTIALS_CONTROLLER - _managed_assets()'
    app_config = Rails.application.config_for(:customization)
    template_id = params[ :template_id ]

    Rails.logger.info 'partials_controller - _managed_assets() - template_id: '\
      + template_id.to_s

    design_template = DesignTemplate.find( template_id )
    all_assets = design_template.managed_assets
    @image_only_assets = []
    @description_only_assets = []
    @assets = []

    all_assets.each { |a|

      if( has_image( a ) && !has_description( a ) )
        @image_only_assets << a
      elsif( !has_image( a ) && has_description( a ) )
        @description_only_assets << a
      else
        # must have both?
        @assets << a
      end
    }
    Rails.logger.info 'partials_controller - _managed_assets() - image_only_assets: '\
      + @image_only_assets.to_s
    Rails.logger.info 'partials_controller - _managed_assets() - description_only_assets: '\
      + @description_only_assets.to_s
    Rails.logger.info 'partials_controller - _managed_assets() - assets: '\
      + @assets.to_s
  end


  def trans_butt_settings
    logger.info 'PARTIALS_CONTROLLER - trans_butt_settings()'
  end

  # This action presents the tags extracted from the AI file, with any
  # tag-specific options, for use when creating or editing a DesignTemplate.
  # See partials_controller_test.rb.
  def design_template_settings
    template_id = params[ :id ]
    @design_template = DesignTemplate.find( template_id )
    @tags = get_tags_array( @design_template )
    @images = get_image_names_array( @design_template )
    @palettes = Palette.all

    # If the user has set options regarding tags extracted from an AI file they
    # go in @prompts
    if json?( @design_template.prompts )
      @prompts = JSON.parse( @design_template.prompts )
    else
      logger.info 'PARTIALS_CONTROLLER - design_template_settings - prompts BAD json!!!'
      logger.info 'PARTIALS_CONTROLLER - design_template_settings - prompts: '\
        + @design_template.prompts.to_s
    end

    logger.info 'PARTIALS_CONTROLLER - design_template_settings - template_id: '\
      + template_id.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @tags: '\
      + @tags.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @images: '\
      + @images.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @prompts: '\
      + @prompts.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @images.length: '\
      + @images.length.to_s
    logger.info 'PARTIALS_CONTROLLER - design_template_settings - @tags.length: '\
      + @tags.length.to_s
  end

  def quick_new
    app_config = Rails.application.config_for(:customization)
    template_id = params[ :template_id ]
    @user_id = params[ :user_id ]

    Rails.logger.info 'partials_controller - quick_new() - template_id: ' + template_id.to_s
    Rails.logger.info 'partials_controller - quick_new() - user_id: ' + @user_id.to_s

    @design_template = DesignTemplate.find( template_id )

    config_hash = { design_template_id: template_id }
    config_hash[ :user_id ] = @user_id if !@user_id.nil?
    Rails.logger.info 'partials_controller - quick_new() - config_hash: '\
      + config_hash.to_s

    @version = Version.new( config_hash )
    @version.save

    version_folder_path = app_config[ 'path_to_quick_version_root' ] + 'template_'\
      + @design_template.id.to_s + '/version_' + @version.id.to_s + '/'
    version_name = @design_template.name + '_' + @version.id.to_s

    @version.name = version_name
    @version.output_folder_path = version_folder_path
    @version.save
  end

  # This action presents each tag and image with ui for setting
  # version-specific options,
  # for use in creating a Version tied to a DesignTemplate.
  def version_settings
    t_id = params[ :template_id ]
    logger.info 'PARTIALS_CONTROLLER - version_settings() - id: ' + t_id.to_s

    @version_id = params[ :version_id ]
    logger.info 'PARTIALS_CONTROLLER - version_settings() - @version_id: '\
      + @version_id.to_s

    @design_template = DesignTemplate.find( t_id )
    @tags = get_tags_array( @design_template )
    @images = get_images_array( @design_template )
    @colors = Color.all
    @fonts = get_ai_fonts()
    @palettes = get_palettes( @design_template )

    logger.info 'PARTIALS_CONTROLLER - version_settings() - @tags: '\
      + @tags.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings() - @images: '\
      + @images.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings() - @images.length: '\
      + @images.length.to_s
    logger.info 'PARTIALS_CONTROLLER - version_settings() - @tags.length: '\
      + @tags.length.to_s

    if !@version_id.nil?
      @version = Version.find( @version_id )
    else
      # if it's nil, make it '' so we can just use it without thinking
      @version_id = ''
    end

    logger.info 'PARTIALS_CONTROLLER - version_settings() - @version: '\
      + @version.to_s

    if !@version.nil?

      # we've got to update this version to reflect the new DesignTemplate,
      # and we've got to do this because the version has to be saved and ready
      # if the user tries to attach a file to it.
      o = { 'design_template_id' => @design_template.id.to_s }
      @version.update( o )

      if @version.save
        logger.info 'PARTIALS_CONTROLLER - version_settings() - VERSION SAVED!'
      else
        logger.info 'PARTIALS_CONTROLLER - version_settings() - VERSION NOT SAVED!'
      end

      values = get_values_object( @version )

      if !values.nil?
        @image_values = values[ VERSION_VALUES_KEY_IMAGE_SETTINGS ]
        @tag_values = values[ VERSION_VALUES_KEY_TAG_SETTINGS ]
        @trans_butt_values = values [ VERSION_VALUES_KEY_TRANS_BUTT_SETTINGS ]
      end

    end

    @prompts = get_prompts_object( @design_template )
  end
end

# Partials Helper
module PartialsHelper
  include DesignTemplatesHelper

  # This method iterates through all of the tags associated with a template
  # and constructs a hash matching tags to Color collections.
  # It then iterates through all of the colors being replaced, and adds keys
  # matching color-to-be-replaced to a Color collection.
  # This is all for use by partials/_version_colors, and the partials/_versions_tags
  # views.
  def get_palettes( template )

    Rails.logger.info 'partials_helper - get_palettes()'
    palettes = {}
    prompts = get_prompts_object( template )
    tag_settings = prompts[ PROMPTS_KEY_TAG_SETTINGS ]

    tag_settings.each do |t|
      use_palette = t[ 1 ][ 'use_palette' ]
      palette_id = t[ 1 ][ 'palette_id' ]

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
    end # each tag setting

    color_settings = prompts[ PROMPTS_KEY_COLOR_SETTINGS ]

#    Rails.logger.info 'partials_helper - get_palettes() color_settings: '\
#      + JSON.pretty_generate( color_settings )

    color_settings.each do |c|
      use_palette = c[ 1 ][ PROMPTS_KEY_REPLACE_COLOR_USE_PALETTE ]
      palette_id = c[ 1 ][ PROMPTS_KEY_REPLACE_COLOR_PALETTE_ID ]

      if use_palette === 'checked'
        begin

          palette = Palette.find( palette_id )
          palettes[ c[0] ] = palette.colors
        rescue ActiveRecord::RecordNotFound
          palettes[ c[0] ] = Color.all
        end
      else
        palettes[ c[0] ] = Color.all
      end


    end # each color setting


#    Rails.logger.info 'PartialsHelper - get_palettes() - palettes: '\
#      + JSON.pretty_generate( palettes )

    palettes
  end
end

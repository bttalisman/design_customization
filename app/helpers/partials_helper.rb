# Partials Helper
module PartialsHelper
  include DesignTemplatesHelper

  # This method iterates through all of the tags associated with a template
  # and constructs a hash matching tags to Color collections.
  def get_palettes( template )
    palettes = {}
    prompts = get_prompts_object( template )
    tag_settings = prompts[ 'tag_settings' ]

    tag_settings.each do |t|
      use_palette = t[ 1 ][ 'use_palette' ]
      palette_id = t[ 1 ][ 'palette_id' ]

      Rails.logger.info 'PartialsHelper - get_palettes() - t: ' + t.to_s
      Rails.logger.info 'PartialsHelper - get_palettes() - use_palette: '\
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

    Rails.logger.info 'PartialsHelper - get_palettes() - palettes: '\
      + palettes.to_s

    palettes
  end
end

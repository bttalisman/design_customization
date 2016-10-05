# Colors Helper
module ColorsHelper
  def swatch( c, settings )
    logger.info 'ColorsHelper - swatch() - settings: ' + settings.to_s

    display = settings[:display]
    id = settings[:id]
    position = settings[:position]

    s = '<div class="color-item" id="' + id.to_s + '" title="'\
      + c.hex_code.to_s + ' - ' + c.description.to_s\
      + '" style="display:' + display.to_s + '; position:' + position.to_s + '; background:' + c.hex_code.to_s\
      + '"></div>'
    s
  end

  def load_extracted_colors( design_template, params )
    if( params[ 'load_colors'] )
      logger.info 'ColorsHelper - load_extracted_colors() - LOADING COLORS'

      color_count = params[ 'color_count' ]
      color_count = if color_count != ''
                      color_count.to_i
                    else
                      0
                    end

      color_count.times do |i|

        p_name = 'color_name' + i.to_s
        color_name = params[ p_name ]

        p_name = 'orig_color_hex' + i.to_s
        orig_color_hex = params[ p_name ]

        p_name = 'orig_color_c' + i.to_s
        orig_color_c = params[ p_name ]
        p_name = 'orig_color_m' + i.to_s
        orig_color_m = params[ p_name ]
        p_name = 'orig_color_y' + i.to_s
        orig_color_y = params[ p_name ]
        p_name = 'orig_color_k' + i.to_s
        orig_color_k = params[ p_name ]


        new_color = Color.create
        new_color.cyan = orig_color_c
        new_color.magenta = orig_color_m
        new_color.yellow = orig_color_y
        new_color.black = orig_color_k

        new_color.hex_code = orig_color_hex
        new_color.description = 'Imported from AI.'
        new_color.save
      end # color_count times
    end

  end



end

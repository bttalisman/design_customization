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
end

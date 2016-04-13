# Palettes Controller
class PalettesController < ApplicationController
  def index
    @palettes = Palette.all

    palettes = Palette.all
    @palettes = []

    palettes.each do |p|
      o = { name: p.name.to_s,
            description: p.description.to_s,
            id: p.id.to_s
      }
      @palettes << o
    end
  end

  def show
    @palette = Palette.find( params[ :id ] )
    @all_colors = Color.all
    @my_colors = @palette.colors
  end

  def edit
    logger.info 'PALETTES_CONTROLLER - edit! - params: ' + params.to_s
    @palette = Palette.find( params[ :id ] )
    @all_colors = Color.all
    @my_colors = @palette.colors

    logger.info 'PALETTES_CONTROLLER - @my_colors: '\
      + JSON.pretty_generate(JSON.parse(@my_colors.to_json))
  end

  def update
    logger.info 'PALETTES_CONTROLLER - update! - params: ' + params.to_s
    @palette = Palette.find( params[ :id ] )
    @palette.update( palette_params )
    logger.info 'PALETTES_CONTROLLER - update - about to save.'
    if @palette.save
      logger.info 'PALETTES_CONTROLLER - update - SUCCESS!'
      redirect_to palette_path
    else
      logger.info 'PALETTES_CONTROLLER - update - FAILURE!'
      render 'new'
    end
  end

  def add
    logger.info 'PALETTES_CONTROLLER - add! - params: ' + params.to_s
    palette = Palette.find( params[ :id ] )
    color = Color.find( params[ :color_id ] )
    palette.colors << color
    render nothing: true
  end

  def remove
    logger.info 'PALETTES_CONTROLLER - remove! - params: ' + params.to_s
    palette = Palette.find( params[ :id ] )
    color = Color.find( params[ :color_id ] )
    palette.colors.delete( color )
    render nothing: true
  end

  def remove_all
    logger.info 'PALETTES_CONTROLLER - remove_all! - params: ' + params.to_s
    palette = Palette.find( params[ :id ] )
    palette.colors.delete_all
    render nothing: true
  end

  def new
    @palette = Palette.new
  end

  def create
    logger.info 'PALETTES_CONTROLLER - create!'

    @palette = Palette.new( palette_params )

    if @palette.save
      logger.info 'PALETTES_CONTROLLER - create - SUCCESS!'
      redirect_to palettes_path
    else

      logger.info 'PALETTES_CONTROLLER - create - FAILURE!'
      render 'new'

    end
  end

  def destroy
    logger.info 'PALETTES_CONTROLLER - destroy'
    @palette = Palette.find( params[ :id ] )
    @palette.destroy
    redirect_to :palettes
  end

  def delete_all
    logger.info 'PALETTES_CONTROLLER - delete_all'
    cs = Palette.all
    cs.each( &:delete )
    render nothing: true
  end

  def palette_params
    params.require( :palette ).permit( :name, :description )
  end
end

class PalettesController < ApplicationController

  def index
    @palettes = Palette.all
  end


  def show
    @palette = Palette.find( params[ :id ] )
  end



  def edit

    logger.info "PALETTES_CONTROLLER - edit! - params: " + params.to_s
    @palette = Palette.find( params[ :id ] )

  end


  def update

    logger.info "PALETTES_CONTROLLER - update! - params: " + params.to_s

    @palette = Palette.find( params[ :id ] )
    @palette.update( palette_params )

    logger.info "PALETTES_CONTROLLER - update - about to save."
    if @palette.save
      logger.info "PALETTES_CONTROLLER - update - SUCCESS!"
      redirect_to palette_path, :notice => "This palette was saved."
    else
      logger.info "PALETTES_CONTROLLER - update - FAILURE!"
      render "new"
    end
  end





  def new
    @palette = Palette.new
  end


  def create

    logger.info "PALETTES_CONTROLLER - create!"

    @palette = Palette.new( palette_params )

    if @palette.save

      logger.info "PALETTES_CONTROLLER - create - SUCCESS!"

      redirect_to palettes_path, :notice => "This palette was saved."
    else

      logger.info "PALETTES_CONTROLLER - create - FAILURE!"
      render "new"

    end



  end


  def destroy
    logger.info "PALETTES_CONTROLLER - destroy"
    @palette = Palette.find( params[ :id ] )
    @palette.destroy
    redirect_to :palettes
  end


  def delete_all
    logger.info 'PALETTES_CONTROLLER - delete_all'
    cs = Palette.all
    cs.each { |c|
      c.delete
    }
    render nothing: true
  end


  def palette_params
       params.require( :palette ).permit( :name )
  end


end

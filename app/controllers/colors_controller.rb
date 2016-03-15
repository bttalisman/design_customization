class ColorsController < ApplicationController



  def index
    @colors = Color.all
  end


  def show
    @color = Color.find( params[ :id ] )
  end



  def edit

    logger.info "COLORS CONTROLLER - edit! - params: " + params.to_s
    @color = Color.find( params[ :id ] )

  end


  def update

    logger.info "COLORS_CONTROLLER - update! - params: " + params.to_s

    @color = Color.find( params[ :id ] )
    @color.update( color_params )

    logger.info "COLORS_CONTROLLER - update - about to save."
    if @color.save
      logger.info "COLORS_CONTROLLER - update - SUCCESS!"
      redirect_to color_path, :notice => "This color was saved."
    else
      logger.info "COLORS_CONTROLLER - update - FAILURE!"
      render "new"
    end
  end





  def new
    @color = Color.new
  end


  def create

    logger.info "COLOR_CONTROLLER - create!"

    @color = Color.new( color_params )

    if @color.save

      logger.info "COLOR_CONTROLLER - create - SUCCESS!"

      redirect_to colors_path, :notice => "This color was saved."
    else

      logger.info "COLOR_CONTROLLER - create - FAILURE!"
      render "new"

    end



  end



  def delete_all
    logger.info 'COLORS_CONTROLLER - delete_all'
    cs = Color.all
    cs.each { |c|
      c.delete
    }
    render nothing: true
  end


  def color_params
       params.require( :color ).permit( :hex_code )
  end



end
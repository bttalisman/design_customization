# Colors Controller
class ColorsController < ApplicationController
  def index
    @colors = Color.all.order( cyan: :asc, magenta: :asc, yellow: :asc, black: :asc )
  end

  def show
    @color = Color.find(params[:id])
  end

  def edit
#    logger.info 'COLORS_CONTROLLER - edit! - params: ' + params.to_s
    @color = Color.find(params[:id])
  end

  def update
#    logger.info 'COLORS_CONTROLLER - update! - params: ' + params.to_s
    @color = Color.find( params[:id] )
    @color.update( color_params )
    if @color.save
      redirect_to color_path
    else
      render 'new'
    end
  end

  def new
    @color = Color.new
  end

  def create
#    logger.info 'COLORS_CONTROLLER - create!'
    @color = Color.new(color_params)
    if @color.save
      redirect_to colors_path
    else
      render 'new'
    end
  end

  def destroy
    logger.info 'COLORS_CONTROLLER - destroy'
    @color = Color.find(params[:id])
    @color.destroy
    redirect_to :colors
  end

  def delete_all
    logger.info 'COLORS_CONTROLLER - delete_all'
    Color.all.delete_all
    render nothing: true
  end

  def color_params
    params.require(:color).permit(:hex_code, :description)
  end
end

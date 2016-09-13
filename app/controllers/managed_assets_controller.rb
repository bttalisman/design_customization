# Assets Controller
class ManagedAssetsController < ApplicationController
  include ApplicationHelper

  def index
    @managed_assets = ManagedAsset.all
  end

  def new
  end

  def create
  end

  def show
    @managed_asset = ManagedAsset.find( params[:id] )
  end

  def edit
    @managed_asset = ManagedAsset.find( params[:id] )
  end


  def destroy
    logger.info 'MANAGED_ASSETS_CONTROLLER - destroy()'
    @managed_asset = ManagedAsset.find( params[:id] )
    @managed_asset.destroy
    redirect_to :managed_assets
  end

  def update
    logger.info 'MANAGED_ASSETS_CONTROLLER - update() - params: ' + params.to_s
    @managed_asset = ManagedAsset.find( params[:id] )
    @managed_asset.update( managed_asset_params )

    if @managed_asset.save
      redirect_to managed_asset_path
    else
      logger.info 'MANAGED_ASSETS_CONTROLLER - update() - FAILURE!'
      render 'new'
    end
  end

  private

  def managed_asset_params
    params.require( :managed_asset ).permit( :image, :name )
  end
end

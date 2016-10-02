# Assets Controller
class ManagedAssetsController < ApplicationController
  include ApplicationHelper
  include UsersHelper

  def index
    managed_assets = ManagedAsset.all
    @managed_assets = []

    managed_assets.each do |a|
      o = { name: a.name.to_s,
            owner: get_full_name( a.user_id ) }
      @managed_assets << o
    end

    Rails.logger.info 'managed_assets_controller - index() - @managed_assets.length: '\
      + @managed_assets.length.to_s
  end


  def new
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


  def create
    logger.info 'MANAGED_ASSETS_CONTROLLER - create() - params: ' + params.to_s

    dt_id = params[ 'design_template_id' ]
    @design_template = DesignTemplate.find( dt_id )
    @managed_asset = @design_template.managed_assets.create( managed_asset_params )

    desc = params[ 'managed_asset' ][ 'description' ]
    image = params[ 'managed_asset' ][ 'image' ]

    if !desc.empty?
      @managed_asset.name = 'Text: ' + desc[0..10] + '...'
    elsif !image.nil?
      @managed_asset.name = 'Image: ' + image.original_filename.to_s
    else
      @managed_asset.name = 'Asset'
    end

    user = get_logged_in_user
    @managed_asset.user_id = user.id if user

    if @managed_asset.save
      redirect_to '/design_templates/' + dt_id + '/edit'
    else
      logger.info 'MANAGED_ASSETS_CONTROLLER - create() - FAILURE!'
      render 'new'
    end
  end


  def update
    logger.info 'MANAGED_ASSETS_CONTROLLER - update() - params: ' + params.to_s
    @managed_asset = ManagedAsset.find( params[:id] )

    @managed_asset.update( managed_asset_params )

    if @managed_asset.save
      redirect_to '/design_templates/' + @managed_asset.design_template_id.to_s\
        + '/edit'
    else
      logger.info 'MANAGED_ASSETS_CONTROLLER - update() - FAILURE!'
      render 'new'
    end
  end

  private

  def managed_asset_params
    params.require( :managed_asset ).permit( :image, :name, :description )
  end
end

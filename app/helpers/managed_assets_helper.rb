# ManagedAssets Helper
module ManagedAssetsHelper

  include DesignTemplatesHelper

  def has_image( ma )
    has_image = !ma.image.original_filename.nil?
    has_image
  end

  def has_description( ma )
    has_desc = !ma.description.empty?
    has_desc
  end

  def get_sorted_managed_assets( design_template )
    Rails.logger.info '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    Rails.logger.info 'managed_assets_helper - get_sorted_managed_assets()'

    return [] if design_template.managed_assets.length == 0

    prefs = get_asset_prefs_object( design_template )
    order = prefs[ ASSET_PREFS_KEY_ORDER ]
    assets = []

    if order.length > 0
      order.each { |id|
        a = ManagedAsset.find( id )
        assets << a if a
      }
    else
      fix_managed_asset_prefs( design_template )
      assets = get_sorted_managed_assets( design_template )
    end
    assets
  end

  def move_asset_up_helper( design_template, asset )
    Rails.logger.info 'managed_assets_helper - move_asset_up_helper()'
    prefs = get_asset_prefs_object( design_template )
    order = prefs[ ASSET_PREFS_KEY_ORDER ]
    i = order.index( asset.id.to_i )

    return if i.nil?
    return if i == 0

    prev = order[ i-1 ]
    order[ i-1 ] = asset.id
    order[ i ] = prev

    design_template.asset_prefs = prefs.to_json
    design_template.save
  end

  def move_asset_down_helper( design_template, asset )
    Rails.logger.info 'managed_assets_helper - move_asset_down_helper()'
    prefs = get_asset_prefs_object( design_template )
    order = prefs[ ASSET_PREFS_KEY_ORDER ]

    i = order.index( asset.id.to_i )
    return if i.nil?
    return if i == (order.length - 1)

    next_val = order[ i+1 ]
    order[ i+1 ] = asset.id
    order[ i ] = next_val

    design_template.asset_prefs = prefs.to_json
    design_template.save
  end

  # This method adds asset prefernces for a template with assets but no
  # preferences
  def fix_managed_asset_prefs( design_template )
    Rails.logger.info 'managed_assets_helper - fix_managed_asset_prefs()'
    assets = design_template.managed_assets.all
    assets.each { |a|
      add_asset_preferences( design_template, a )
    }
  end


  def add_asset_preferences( design_template, asset )
    Rails.logger.info 'managed_assets_helper - add_asset_preferences()'
    prefs = get_asset_prefs_object( design_template )
    order = prefs[ ASSET_PREFS_KEY_ORDER ]
    order << asset.id
    Rails.logger.info 'managed_assets_helper - add_asset_preferences() - order: ' + order.to_s

    design_template.asset_prefs = prefs.to_json
    design_template.save
  end

  def add_managed_asset_and_process_prefs( design_template, asset )
    Rails.logger.info 'managed_assets_helper - add_managed_asset_and_process_prefs()'
    design_template.managed_assets << asset
    add_asset_preferences( design_template, asset )
    design_template.save
  end

  def remove_managed_asset_and_process_prefs( design_template, asset )
    Rails.logger.info 'managed_assets_helper - remove_managed_asset_and_process_prefs()'
    design_template.managed_assets.delete( asset )
    prefs = get_asset_prefs_object( design_template )
    order = prefs[ ASSET_PREFS_KEY_ORDER ]
    order.delete( asset.id )

    design_template.asset_prefs = prefs.to_json
    design_template.save
  end




end

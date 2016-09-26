# ManagedAssets Helper
module ManagedAssetsHelper


  def has_image( ma )
    has_image = !ma.image.original_filename.nil?
    has_image
  end

  def has_description( ma )
    has_desc = !ma.description.empty?
    has_desc
  end

end

# Collage Model
# A Collage is a collection of images.  A user creating a version of a template
# has the option to replace an image with a ReplacementImage or a Collage.
# illustrator_processing/searchAndReplaceImages.jsx, when using a Collage,
# will rotate through the images found in the Collage folder.
class Collage < ActiveRecord::Base
  belongs_to :version

  after_save :set_path

  private

  # Every collage has a path.  This folder will hold all of the images that
  # make up this collage.
  def set_path
    Rails.logger.info 'Collage - set_path()'
    app_config = Rails.application.config_for( :customization )
    collage_root = app_config[ 'path_to_collage_root' ]
    path = collage_root + self[:id].to_s + '/'
    Rails.logger.info 'Collage - set_path() - path: ' + path.to_s
    self[ :path ] = path
  end
end

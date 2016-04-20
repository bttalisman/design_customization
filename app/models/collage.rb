# Collage Model
class Collage < ActiveRecord::Base
  belongs_to :version
  include CollagesHelper

  after_save :build_collage_folder

  private

  # This method is called after the collage is saved.  It creates a folder,
  # contacts Instagram and downloads images based on the query into that
  # folder.
  def build_collage_folder
#    path = @@path_to_collage_root + '/collage_' + self[:id].to_s
    path = @@path_to_collage_root + '/test_collage'
    logger.info 'COLLAGE - build_collage_folder() - path: ' + path.to_s

    self[:path] = path
    FileUtils.mkdir_p( path ) unless File.directory?( path )
  end
end

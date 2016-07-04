# Collage Model
class Collage < ActiveRecord::Base
  belongs_to :version

  after_save :set_path
    
    
  private
    
  def set_path
    Rails.logger.info 'Collage - set_path()'
    app_config = Rails.application.config_for(:customization)
    collage_root = app_config[ 'path_to_collage_root' ]
    path = collage_root + '/' + self[:id].to_s
    Rails.logger.info 'Collage - set_path() - path: ' + path.to_s
    self[:path] = path
  end

end

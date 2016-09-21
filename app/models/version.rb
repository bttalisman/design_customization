# Version Model
class Version < ActiveRecord::Base
  has_many :replacement_images, dependent: :destroy
  has_many :collages, dependent: :destroy

  belongs_to :design_template
  belongs_to :user

  before_save :default_values

  def default_values
    self.values ||= '{ "' + VERSION_VALUES_KEY_TAG_SETTINGS + '" : {}, "'\
      + VERSION_VALUES_KEY_IMAGE_SETTINGS + '" : {} }'
  end
end

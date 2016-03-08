class Version < ActiveRecord::Base

  has_many :replacement_images, dependent: :destroy

  belongs_to :design_template

  before_save :default_values

  def default_values
    self.values ||= '{ "tag_settings" : {}, "image_settings" : {} }'
  end






end

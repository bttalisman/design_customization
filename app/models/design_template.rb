# DesignTemplate Model
class DesignTemplate < ActiveRecord::Base
  has_many :versions, dependent: :destroy

  has_attached_file :original_file,
                    default_url: '/images/missing.png',
                    path: ':rails_root/public/system/:class/:attachment/:id_partition/:filename',
                    url: '/system/:class/:attachment/:id_partition/:basename.:extension'

  validates_attachment_content_type :original_file,
                                    content_type: 'application/postscript'

  before_save :default_prompts

  def default_prompts
    self.prompts ||= '{ "' + PROMPTS_KEY_TAG_SETTINGS + '" : {}, "'\
      + PROMPTS_KEY_IMAGE_SETTINGS + '" : {} }'
  end
end

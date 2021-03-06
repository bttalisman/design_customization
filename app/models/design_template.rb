# DesignTemplate Model
class DesignTemplate < ActiveRecord::Base

  include ApplicationHelper

  has_many :versions, dependent: :destroy
  has_and_belongs_to_many :managed_assets

  belongs_to :user


  has_attached_file :original_file,
                    default_url: '/images/missing.png',
                    path: ':rails_root/public/system/:class/:attachment/:id_partition/:filename',
                    url: '/system/:class/:attachment/:id_partition/:basename.:extension'

  validates_attachment_content_type :original_file,
                                    content_type: 'application/postscript'

  before_save :default_prompts
  before_save :default_asset_prefs
  before_post_process :rename_original_file

  def default_prompts
    self.prompts ||= '{ "' + PROMPTS_KEY_TAG_SETTINGS + '": {}, "'\
      + PROMPTS_KEY_IMAGE_SETTINGS + '" : {}, "' + PROMPTS_KEY_COLOR_SETTINGS + '": {} }'
  end

  def default_asset_prefs
    self.asset_prefs ||= '{ "' + ASSET_PREFS_KEY_ORDER + '" : [] }'
  end


  def rename_original_file
      extension = File.extname(original_file_file_name).downcase
      base_name= File.basename(original_file_file_name, '.ai')
      base_name = make_suitable_file_name( base_name )
      self.original_file.instance_write :file_name, "#{base_name}#{extension}"
  end
end

class ManagedAsset < ActiveRecord::Base
  belongs_to :design_template

  has_attached_file :image,
                    default_url: '/images/missing.png',
                    path: ':rails_root/public/system/:class/:attachment/:id_partition/:filename',
                    url: '/system/:class/:attachment/:id_partition/:basename.:extension'

  validates_attachment_content_type :image,
                                    content_type: ['image/jpeg', 'image/png']

end

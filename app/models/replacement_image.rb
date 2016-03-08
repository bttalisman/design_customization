class ReplacementImage < ActiveRecord::Base

  belongs_to :version

  has_attached_file :uploaded_file,
    :default_url => "/images/missing.png",
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:filename",
    :url => "/system/:class/:attachment/:id_partition/:basename.:extension"

  validates_attachment_content_type :uploaded_file,
    :content_type => 'image/jpeg'

end

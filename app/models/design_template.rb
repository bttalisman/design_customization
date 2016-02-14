class DesignTemplate < ActiveRecord::Base

    has_many :versions

    has_attached_file :original_file,
      :default_url => "/images/missing.png",
      :path => "public/system/:class/:attachment/:id_partition/:filename",
      :url => "/system/:class/:attachment/:id_partition/:basename.:extension"


    validates_attachment_content_type :original_file,
      :content_type => 'application/postscript'

end

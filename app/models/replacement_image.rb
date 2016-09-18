require 'zip'
require 'fileutils'

# ReplacementImage Model
# A ReplacementImage is just an uploaded image. A user creating a version of a template
# has the option to replace an image with a ReplacementImage or a Collage.
# illustrator_processing/searchAndReplaceImages.jsx, when using a ReplacementImage,
# will just ask Illustrator to place this file.
class ReplacementImage < ActiveRecord::Base

  include ApplicationHelper

  belongs_to :version

  has_attached_file :uploaded_file,
                    default_url: '/images/missing.png',
                    path: ':rails_root/public/system/:class/:attachment/:id_partition/:filename',
                    url: '/system/:class/:attachment/:id_partition/:basename.:extension'

  validates_attachment_content_type :uploaded_file,
                                    content_type: ['image/jpeg', 'image/png', 'application/zip']

  before_post_process :rename_uploaded_file


  # This method gets the path of this ReplacementImage.  If the uploaded_file
  # is an image, the returned path is just the path to that image file.  If
  # the uploaded_file is a zip archive, the returned path is the path to the
  # folder into which images are extracted.
  def get_path

    if uploaded_file.path
      Rails.logger.info 'replacement_image - get_path() - has uploaded_file.path!'
      return_path = uploaded_file.path
      ext_name = File.extname( return_path )
      return_path = File.dirname( return_path ) + '/'\
        + ZIP_FILE_EXTRACTED_SUBFOLDER_NAME + '/' if( ext_name == '.zip' )
    else
      Rails.logger.info 'replacement_image - get_path() - does not have uploaded_file.path!'
      app_config = Rails.application.config_for( :customization )
      ri_root = app_config[ 'path_to_replacement_image_root' ]
      return_path = ri_root + self[:id].to_s.rjust(3, '0') + '/'
      Dir.mkdir( return_path ) if !Dir.exist?( return_path )
    end

    Rails.logger.info 'replacement_image - get_path() - return_path: ' + return_path.to_s

    return_path
  end


  def rename_uploaded_file
      extension = File.extname(uploaded_file_file_name).downcase
      base_name= File.basename(uploaded_file_file_name, '.*' )
      base_name = make_suitable_file_name( base_name )
      self.uploaded_file.instance_write :file_name, "#{base_name}#{extension}"
  end


  def unzip
    uploaded_file = self.uploaded_file
    Rails.logger.info 'replacement_image - unzip() - uploaded_file: '\
      + uploaded_file.to_s

    if uploaded_file_content_type == 'application/zip'
      source_folder = File.dirname( uploaded_file.path )
      dest_folder = source_folder + '/' + ZIP_FILE_EXTRACTED_SUBFOLDER_NAME + '/'
      Dir.mkdir( dest_folder ) if !Dir.exist?( dest_folder )

      Zip::File.open( uploaded_file.path ) do |zip_file|
        zip_file.each do |entry|
          dest_file = dest_folder + entry.name
          entry.extract( dest_file ) if !File.exist?( dest_file )
        end
      end

      FileUtils.rm_rf( dest_folder + '__MACOSX' )
    end # it's a zip file
  end

end

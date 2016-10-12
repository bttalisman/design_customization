module GoogleDriveHelper

  # Returns the number of rendered images in the render folder.
  def get_local_render_image_count( version, plus_size )
    local_render_folder = get_local_render_folder( version )
    i = 0
    Dir.entries( local_render_folder ).each do |name|
      # skip folders
      next if File.directory? name
      next if name == '.DS_Store'

      Rails.logger.info 'VERSIONS_HELPER - get_local_render_image_count() - name: '\
        + name.to_s

      if plus_size
        next if !name.to_s.include?( 'Plus' )
      else
        next if name.to_s.include?( 'Plus' )
      end
      i += 1
    end # each entry in dir
    Rails.logger.info 'VERSIONS_HELPER - get_local_render_image_count() - plus_size: '\
      + plus_size.to_s
    Rails.logger.info 'VERSIONS_HELPER - get_local_render_image_count() - i: '\
      + i.to_s
    i
  end

  # This id is used for downloading rendered images.
  def get_google_drive_folder_id( folder_name )
    command = %Q[ gdrive list -q 'name = "#{folder_name}" and mimeType = "application/vnd.google-apps.folder"' > tmp/output.txt ]

    begin
      system( command )
    rescue Error
    end

    file = File.new( 'tmp/output.txt', 'r' )
    first_line = file.gets
    second_line = file.gets
    file.close

    if second_line
      data = second_line.split( ' ' )
      id = data[0] if data.kind_of?(Array)
    end
    Rails.logger.info 'VERSIONS_HELPER - get_google_drive_folder_id() folder_name: ' + folder_name.to_s
    Rails.logger.info 'VERSIONS_HELPER - get_google_drive_folder_id() id: ' + id.to_s
    id
  end

  # This method copies rendered images from the remote render folder on
  # Google drive into the local render folder.  It then renames all images
  # to image_###.png or image_Plus_###.png
  def update_local_render_folder( version )
    app_config = Rails.application.config_for( :customization )
    render_root_folder = app_config[ 'path_to_local_render_folder_root' ]
    local_render_folder = get_local_render_folder( version )

    paths = get_paths( version )
    output_file_base_name = paths[ :output_file_base_name ]

    FileUtils.mkdir_p( local_render_folder )\
      unless File.directory?( local_render_folder )

    folder_id = get_google_drive_folder_id( output_file_base_name )
    command = %Q[ gdrive download --recursive --path '#{render_root_folder}' #{folder_id} ]

    return if folder_id.nil?

    begin
      system( command )
    rescue Error
    end

    path = render_root_folder + output_file_base_name

    Rails.logger.info 'versions_helper - update_local_render_folder() - about to rename contents of : '\
      + path.to_s


    i = 0
    Dir.open( path ).each do |p|
      next if File.extname(p) != '.png'
      next if p.to_s.include?( 'Plus' )
      newname = 'image_' + i.to_s.rjust( 3, '0' ) + '.png'
      begin
        FileUtils.mv( "#{path}/#{p}", "#{path}/#{newname}", { :force => true } )
      rescue ArgumentError
      end
      i += 1
    end

    # Rename plus-sized images
    i = 0
    Dir.open( path ).each do |p|
      next if File.extname(p) != '.png'
      next if !p.to_s.include?( 'Plus' )
      newname = 'image_Plus_' + i.to_s.rjust( 3, '0' ) + '.png'
      begin
        FileUtils.mv( "#{path}/#{p}", "#{path}/#{newname}", { :force => true } )
      rescue ArgumentError
      end
      i += 1
    end

  end

end

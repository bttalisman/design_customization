module ApplicationHelper


  @@versions_folder = Rails.root.to_s + "/public/system/versions/"

  def is_json?( s )
    begin
      !!JSON.parse(s)
    rescue
      false
    end
  end

  def guarantee_final_slash( folder_path )
    logger.info "APPLICATION_HELPER - guarantee_final_slash() - folder_path: " + folder_path
    f = folder_path
    if( folder_path[-1, 1] != '/') then
      logger.info "GUARANTEE_FINAL_SLASH - appending!!"
      f = folder_path + '/'
    end
    f
  end

  def path_to_data_file( path_to_ai_file )
    source_folder = File.dirname( path_to_ai_file )
    base_name = File.basename( path_to_ai_file, '.ai' )
    data_file = source_folder + "/" + base_name +  "_data.jsn"
    data_file
  end




end

module ApplicationHelper





  def path_to_data_file( design_template )

    file = design_template.original_file
    source_path = Rails.root.to_s + "/" + file.path

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_data.jsn"

    data_file

  end



  def path_to_tags_file( design_template )

    file = design_template.original_file
    source_path = Rails.root.to_s + "/" + file.path

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_tags.jsn"

    data_file

  end



  def tags_file_exist?( design_template )

    path = path_to_tags_file( design_template )
    exists = File.exist?( path )

    exists

  end



  def get_tags_array( design_template )

    tags_file = path_to_tags_file( design_template )
    exists = File.exist?( tags_file )


    logger.info "APPLICATION_HELPER - get_tags_array - exists: " + exists.to_s

    tags_string = ''
    tags = nil

    if exists then

      File.open( tags_file,"r" ) do |f|
        tags_string = f.read()
      end

      tags = JSON.parse( tags_string )

    end

    tags

  end


end

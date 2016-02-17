module ApplicationHelper





  def path_to_data_file( design_template )

    file = design_template.original_file
    source_path = Rails.root.to_s + "/" + file.path

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_data.jsn"

    data_file

  end



  def path_to_prompts_file( design_template )

    file = design_template.original_file
    source_path = Rails.root.to_s + "/" + file.path

    source_folder = File.dirname( source_path )
    data_file = source_folder + "/" + File.basename( source_path, '.ai' ) +  "_prompts.jsn"

    data_file

  end



  def prompts_file_exist?( design_template )

    path = path_to_prompts_file( design_template )
    exists = File.exist?( path )

    exists

  end



  def get_prompts_array( design_template )

    prompts_file = path_to_prompts_file( design_template )
    exists = File.exist?( prompts_file )

    prompts_string = ''
    prompts = nil

    if exists then

      File.open( prompts_file,"r" ) do |f|
        prompts_string = f.read()
      end

      prompts = JSON.parse( prompts_string )

    end

    prompts

  end


end

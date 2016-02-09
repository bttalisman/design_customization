class HomeController < ApplicationController


  @@path_to_runner_script = "/Users/bent/customization/bin/illustrator_processing/run_AI_script.rb"
  @@path_to_extract_script = "/Users/bent/customization/bin/illustrator_processing/extractPrompts.jsx"
  @@path_to_search_replace_script = "/Users/bent/customization/bin/illustrator_processing/searchAndReplace.jsx"


  def generate_customization_view( original_file )

    logger.info "GENERATE_CUSTOMIZATION_VIEW"

    original_folder = File.dirname( original_file.path )
    config_extract_prompts_path = original_folder + "/config_extract_prompts.jsn"
    config_search_replace_path = original_folder + "/config_search_replace.jsn"


    # generate config_extract_prompts.jsn

    o = {
      "source file" => original_file.path,
      "script file" => @@path_to_extract_script,
      "output folder" => "/Users/bent/customization/working/versions/testDesign/v1"
    }

    File.open( config_extract_prompts_path, "w" ) do |file|
      file.write o.to_json
    end


    # generate config_search_replace.jsn

    o = {
      "source file" => original_file.path,
      "script file" => @@path_to_search_replace_script,
      "output folder" => "/Users/bent/customization/working/versions/testDesign/v1"
    }

    File.open( config_search_replace_path, "w" ) do |file|
      file.write o.to_json
    end



    # run -- perl run_AI_script.pl "config_extract_prompts.jsn"

    sys_com = "ruby " + @@path_to_runner_script + " '" + config_extract_prompts_path + "'"
    system( sys_com )

  end

  helper_method :generate_customization_view





  def index
  end

end

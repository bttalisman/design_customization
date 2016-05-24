# DesignTemplates Helper
module DesignTemplatesHelper
  # the path to the tags file is based on the path to the original ai file.
  def path_to_tags_file( design_template )
    file = design_template.original_file
    source_path = file.path.to_s
    source_folder = File.dirname( source_path )
    data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
      + '_tags.jsn'
    data_file
  end

  # the path to the images file is based on the path to the original ai file.
  def path_to_images_file( design_template )
    file = design_template.original_file
    source_path = file.path.to_s
    source_folder = File.dirname( source_path )
    data_file = source_folder + '/' + File.basename( source_path, '.ai' )\
      + '_images.jsn'
    data_file
  end

  def tags_file_exist?( design_template )
    path = path_to_tags_file( design_template )
    exists = File.exist?( path )
    exists
  end

  # This method returns an array of extracted tags.  These are the strings
  # of text within an AI file that will be replaced by versions of this
  # template.
  def get_tags_array( design_template )
    tags_file = path_to_tags_file( design_template )
    exists = File.exist?( tags_file )

    tags_string = ''
    tags = [] # default value
    if exists
      File.open( tags_file, 'r' ) do |f|
        tags_string = f.read
      end
      tags = JSON.parse( tags_string ) if json?( tags_string )
    end
    tags
  end

  # Returns true if this template is built from an AI file containing tags.
  # More specifically, true if the tags file found in this version's folder
  # represents a valid, non-empty json array of tag names.
  def tags?( design_template )
    a = get_tags_array( design_template )
    return false if a.empty?
    true
  end

  # Returns true if this template is built from an AI file containing images.
  # More specifically, true if the images file found in this version's folder
  # represents a valid, non-empty json array of image names.
  def images?( design_template )
    a = get_images_array( design_template )
    return false if a.empty?
    true
  end

  # This method returns an array of extracted image names.  These are the
  # placed items within an AI file that will be replaced by versions of this
  # template.
  def get_images_array( design_template )
    # Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_images_array()'
    images_file = path_to_images_file( design_template )
    # Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_images_array() - images_file: '\
    # + images_file.to_s
    exists = File.exist?( images_file )
    # Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_images_array - exists: '\
    # + exists.to_s
    images_string = ''
    images = []
    if exists
      File.open( images_file, 'r' ) do |f|
        images_string = f.read
      end
      images = JSON.parse( images_string ) if json?( images_string )
    end
    images
  end

  # A design_template's prompts describes any extensible settings
  # presented by versions of this template, such as replace this image?, allow
  # users to set the color of this text?
  #
  # tag_settings:
  #   tag_name:
  #     prompt: 'stuff'
  #     max_length: '33'
  #     min_length: '2'
  #     pick_color: 'checked'
  #     use_palette: 'checked'
  #     palette_id: '4'
  #
  # image_settings:
  #   image_name:
  #     replace_image: 'checked'
  #
  def get_prompts_object( design_template )
    prompts_string = design_template.prompts
    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - get_prompts_object() - '\
      + 'prompts_string: ' + prompts_string.to_s
    prompts = JSON.parse( prompts_string ) if json?( prompts_string )
    prompts
  end

  # This method makes a folder to temporarily hold output.  The folder is
  # called 'output' and it's located in the design template folder.
  def make_output_folder( design_template )
    # the illustrator scripts place all output
    # in a subfolder of the folder containing the original file, and later
    # moved to wherever
    source_folder = get_design_template_folder( design_template )
    ai_output_folder = source_folder + '/output'
    FileUtils.mkdir_p( ai_output_folder )\
        unless File.directory?( ai_output_folder )
  end

  # This method returns the path to the specified DesignTemplate's working
  # folder.
  def get_design_template_folder( design_template )
    file = design_template.original_file
    source_path = file.path
    source_folder = File.dirname( source_path )
    source_folder
  end

  # This method returns the path to the configuration file for extracting tags,
  # to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def tags_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - tags_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - tags_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/config_extract_tags.jsn'
    config_file
  end

  # This method returns the path to the configuration file for extracting images,
  # to be used as an argument to the run_AI_script script.  The options
  # parameter must contain either 'design_template_id' or 'design_template'
  def images_config_file_name( options = {} )
    dt_id = options[ 'design_template_id' ]
    design_template = options[ 'design_template' ]

    Rails.logger.info 'design_templates_helper - images_config_file_name() - options: '\
      + options.to_s

    dt = if dt_id.nil?
           design_template
         else
           DesignTemplate.find( dt_id )
         end

    Rails.logger.info 'design_templates_helper - images_config_file_name() - dt: '\
      + dt.to_s

    dt_folder = get_design_template_folder( dt )
    config_file = dt_folder + '/config_extract_images.jsn'
    config_file
  end

  # This method will run the necessary scripts to extract images and tags
  # info from an AI file.  If config/customization.yml[ 'run_remotely' ] then
  # HTTP requests will be sent to the remote server, otherwise local
  # system calls will be executed.
  def process_original( design_template )
    extract_tags( design_template )
    extract_images( design_template )
  end

  def extract_tags( design_template )
    app_config = Rails.application.config_for(:customization)
    run_remotely = app_config['run_remotely']

    config_file = tags_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    config = {}
    config[ 'source file' ] = design_template.original_file.path
    config[ 'script file' ] = app_config[ 'path_to_extract_tags_script' ]
    config[ 'output folder' ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    make_output_folder( design_template )

    if run_remotely
      extract_tags_send_remote( design_template )
    else
      extract_tags_system_call( design_template )
    end
  end

  def extract_images( design_template )
    app_config = Rails.application.config_for(:customization)
    run_remotely = app_config['run_remotely']

    config_file = images_config_file_name( 'design_template' => design_template )
    source_folder = get_design_template_folder( design_template )

    Rails.logger.info 'DESIGN_TEMPLATES_HELPER - extract_images() - config_file: '\
      + config_file.to_s

    config = {}
    config[ 'source file' ] = design_template.original_file.path
    config[ 'script file' ] = app_config[ 'path_to_extract_images_script' ]
    config[ 'output folder' ] = source_folder

    File.open( config_file, 'w' ) do |f|
      f.write( config.to_json )
    end

    make_output_folder( design_template )

    if run_remotely
      extract_images_send_remote( design_template )
    else
      extract_images_system_call( design_template )
    end
  end

  def extract_tags_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
      + 'design_template: ' + design_template.to_s
    Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
      + 'remote_host: ' + remote_host.to_s
    uri_string = remote_host + '/do_extract_tags?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - extract_tags_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def extract_images_send_remote( design_template )
    Rails.logger.info 'design_templates_helper - extract_images_send_remote()'
    uri_string = remote_host + '/do_extract_images?design_template_id='\
      + design_template.id.to_s
    uri = URI.parse( uri_string )

    t = Thread.new do
      response = Net::HTTP.get_response(uri)
      Rails.logger.info 'design_templates_helper - extract_images_send_remote() - '\
        + 'response.code: ' + response.code.to_s
    end

    # Wait until t gets back.  This hangs if one machine is serving both
    # requests.
#    t.join
  end

  def extract_tags_system_call( design_template )
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for(:customization)
    path = app_config['path_to_runner_script']

    sys_com = 'ruby ' + path + ' "'\
      + tags_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end

  def extract_images_system_call( design_template )
    Rails.logger.info 'design_templates_helper - extract_images_system_call() - '\
      + 'design_template: ' + design_template.to_s
    app_config = Rails.application.config_for(:customization)
    path = app_config['path_to_runner_script']

    sys_com = 'ruby ' + path + ' "'\
      + images_config_file_name( 'design_template' => design_template ) + '"'
    Rails.logger.info 'design_templates_helper - extract_tags_system_call() - '\
      + 'about to run sys_com: ' + sys_com.to_s
    system( sys_com )
  end
end

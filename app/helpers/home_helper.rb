# Home Helper
module HomeHelper

  include VersionsHelper
  include DesignTemplatesHelper

  def make_trans_butt_version( params )

    Rails.logger.info 'HomeHelper - make_trans_butt_version() - params: '\
      + params.to_s

    app_config = Rails.application.config_for( :customization )

    text_processing_folder = app_config[ 'path_to_text_processing_folder' ]
    script_path = app_config[ 'path_to_split_text_script' ]
    path_to_doc = text_processing_folder + 'text_processing.ai'
    path_to_config = text_processing_folder + 'config.json'
    path_to_data = text_processing_folder + 'text_data.jsn'
    output_folder = text_processing_folder + 'output/'

    config = {}
    config[ RUNNER_CONFIG_KEY_SOURCE_FILE ] = path_to_doc
    config[ RUNNER_CONFIG_KEY_SCRIPT_FILE ] = script_path
    config[ RUNNER_CONFIG_KEY_OUTPUT_FOLDER ] = output_folder
    config[ RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME ] = ''

    File.open( path_to_config, 'w' ) do |f|
      f.write( config.to_json )
    end

    data = {}
    data[ 'text' ] = params[ 'text' ]
    data[ 'heightToWidthRatio' ] = params[ 'h_to_w' ]
    data[ 'color' ] = params[ 'color' ]
    data[ 'width' ] = params[ 'width' ]
    data[ 'align' ] = params[ 'align' ]

    File.open( path_to_data, 'w' ) do |f|
      f.write( data.to_json )
    end

    runner_path = app_config[ 'path_to_runner_script' ]
    sys_com = 'ruby ' + runner_path + ' "' + path_to_config + '"'
    Rails.logger.info 'home_helper - make_trans_butt_version() - about to run '\
      + 'sys_com: ' + sys_com.to_s
    system( sys_com )

    dt = DesignTemplate.find( 57 )

    version = Version.new
    version.design_template = dt
    version.save

    version.update( 'output_folder_path' => '/Users/bent/temp/version_output/',
                    'name' => 'trans-butt' )

    image_settings = {}
    tag_settings = {}

    ri_path = output_folder + 'left.png'
    file = File.new( ri_path )
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save

    o = { VERSION_VALUES_KEY_RI_ID => ri.id,
          VERSION_VALUES_KEY_PATH => ri_path,
          VERSION_VALUES_KEY_TYPE => IMAGE_TYPE_REPLACEMENT_IMAGE }
    image_settings[ 'LEFT' ] = o


    ri_path = output_folder + 'right.png'
    file = File.new( ri_path )
    ri = ReplacementImage.new
    ri.uploaded_file = file
    ri.save

    o = { VERSION_VALUES_KEY_RI_ID => ri.id,
          VERSION_VALUES_KEY_PATH => ri_path,
          VERSION_VALUES_KEY_TYPE => IMAGE_TYPE_REPLACEMENT_IMAGE }
    image_settings[ 'RIGHT' ] = o


    values = { VERSION_VALUES_KEY_TAG_SETTINGS => tag_settings,
               VERSION_VALUES_KEY_IMAGE_SETTINGS => image_settings }


    Rails.logger.info 'home_helper - make_trans_butt_version() - values: '\
      + JSON.pretty_generate( values )

    version.values = values.to_json
    process_version( version, 'runai' => 'true' )\

    version.save
  end
end

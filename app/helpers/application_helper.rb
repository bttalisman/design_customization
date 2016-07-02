# Application Helper
require 'net/http'
require 'uri'

module ApplicationHelper
  class BailOutOfProcessing < StandardError
  end

  def clear_insta_token
    Rails.logger.info 'ApplicationHelper - clear_insta_token()'
    session[:insta_token] = nil
    render 'home/tools'
  end

  def check_insta_token
    Rails.logger.info 'ApplicationHelper - check_insta_token()'
    get_insta_token if session[:insta_token].nil?
  end

  def get_insta_token
    Rails.logger.info 'ApplicationHelper - get_insta_token()'
    url = 'https://api.instagram.com/oauth/authorize/?'\
      + 'client_id=2b45daba4e154a6cb20060193db7ebfc&redirect_uri='\
      + local_host + '/process_code&response_type=code'
    redirect_to url
  end

  def local_host
    request.protocol + request.host + ':' + request.port.to_s
  end

  def remote_host
    app_config = Rails.application.config_for(:customization)
    host = app_config[ 'remote_server_uri' ]
    logger.info 'application_helper - remote_host() - host: ' + host.to_s
    host
  end

  def json?( s )
    # double bang forces a boolean context for whatever parse returns, without
    # changing it's boolean value
    !!JSON.parse(s)
  rescue
    false
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def is_integer? string
    true if Integer(string) rescue false
  end

  def guarantee_final_slash( folder_path )
    Rails.logger.info( 'application_helper - guarantee_final_slash() - '\
      + 'folder_path' + folder_path.to_s )
    f = folder_path
    f = folder_path + '/' if folder_path[-1, 1] != '/'
    f
  end

  # All necessary data are written to the folder containing the original AI
  # file
  def path_to_data_file( path_to_ai_file )
    source_folder = File.dirname( path_to_ai_file )
    base_name = File.basename( path_to_ai_file, '.ai' )
    data_file = source_folder + '/' + base_name + '_data.jsn'
    data_file
  end

  def bool_display_text( b )
    t = if b.to_s == 'true'
          'yes'
        else
          'no'
        end
    t
  end

  def time_display_text(datetime)
    time = datetime.in_time_zone('Pacific Time (US & Canada)')
    time.strftime('%-m/%-d/%y: %H:%M %Z')
  end

  def load_array_file( path )
    exists = File.exist?( path )
    a_string = ''
    a = [] # default value
    if exists
      File.open( path, 'r' ) do |f|
        a_string = f.read
      end
      a = JSON.parse( a_string ) if json?( a_string )
    end
    a
  end
end

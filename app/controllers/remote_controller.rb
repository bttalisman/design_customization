# Controller for handling remote method calls
class RemoteController < ApplicationController
  include ApplicationHelper
  include VersionsHelper
  include DesignTemplatesHelper

  def do_process_version
    version_id = params[ 'version_id' ]
    logger.info 'REMOTECONTROLLER - do_process_version() - params: '\
      + params.to_s

    version = Version.find( version_id )
    process_version_system_call( version ) if !version.nil?

    logger.info 'REMOTECONTROLLER - do_process_version() - DONE!'
    render nothing: true
  end

  def do_extract_tags
    dt_id = params[ 'design_template_id' ]
    logger.info 'REMOTECONTROLLER - do_extract_tags() - params: '\
      + params.to_s

    extract_tags_system_call( 'design_template_id' => dt_id )

    logger.info 'REMOTECONTROLLER - do_extract_tags() - DONE!'
    render nothing: true
  end

  def do_extract_images
    dt_id = params[ 'design_template_id' ]
    logger.info 'REMOTECONTROLLER - do_extract_images() - params: '\
      + params.to_s

    extract_images_system_call( 'design_template_id' => dt_id )

    logger.info 'REMOTECONTROLLER - do_extract_images() - DONE!'
    render nothing: true
  end


end

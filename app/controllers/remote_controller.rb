# Controller for handling remote method calls
class RemoteController < ApplicationController
  include ApplicationHelper
  include VersionsHelper

  def do_run_ai
    version_id = params[ 'version_id' ]
    logger.info 'REMOTECONTROLLER - do_run_ai() - params: '\
      + params.to_s

    system_call( 'version_id' => version_id )

    logger.info 'REMOTECONTROLLER - do_run_ai() - DONE!'
    render nothing: true
  end
end

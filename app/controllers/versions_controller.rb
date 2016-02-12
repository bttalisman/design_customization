class VersionsController < ApplicationController

    def index
      @versions = Version.all
    end

    def edit
    end

    def create
      @version = Version.new( version_params )

      if @version.save
        redirect_to versions_path, :notice => "This version was saved."
      else
        render "new"
      end

    end

    def new
      @version = Version.new
      @design_templates = DesignTemplate.all
    end

    def update
    end

    def show
      logger.info "versions_controller - show - id: " + params[ :id ].to_s
      @version = Version.find( params[ :id ] )
    end

    def destroy
    end


    private

    def version_params
       params.require(:version).permit( :output_folder_path, :values, :design_template_id )
    end



end

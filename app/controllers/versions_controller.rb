class VersionsController < ApplicationController

    def index
      @versions = Version.all
    end

    def edit
      @version = Version.find( params[ :id ] )
      @design_template = @version.design_template
    end


    def update
      @version = Version.find( params[ :id ] )
      @version.update( version_params )

      logger.info "UPDATE - version_params: " + version_params.to_s

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

    def create
      @version = Version.new( version_params )

      logger.info "VERSION_CONTROLLER - create - version_params: " + version_params.to_s

      if @version.save
        redirect_to versions_path, :notice => "This version was saved."
      else
        render "new"
      end

    end


    def show
      @version = Version.find( params[ :id ] )
      @design_template = @version.design_template

      logger.info "version_controller - show - @version: " + @version.to_s
      logger.info "version_controller - show - @design_template: " + @design_template.to_s

      if @design_template == nil then
        @design_template = DesignTemplate.new
      end

    end


    def destroy

      logger.info "VERSIONS_CONTROLLER - destroy"
      @version = Version.find( params[ :id ] )

      @version.destroy

      redirect_to :versions

    end



    private

    def version_params
       params.require(:version).permit( :output_folder_path, :values, :name, :design_template_id )
    end



end

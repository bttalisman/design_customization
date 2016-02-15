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

      template_id = @version.design_template.id

      versions_folder = Rails.root.to_s + "/public/system/versions/"


      logger.info "VERSION_CONTROLLER - create"
      logger.info "VERSION_CONTROLLER - create - template_id: " + template_id.to_s
      logger.info "VERSION_CONTROLLER - create - version_params: " + version_params.to_s
      logger.info "VERSION_CONTROLLER - create - params[ 'prompt_data' ]: " + params[ 'prompt_data' ].to_s
      logger.info "VERSION_CONTROLLER - create - versions_folder: " + versions_folder.to_s





      if @version.save

        version_output_folder = versions_folder + @version.id.to_s
        FileUtils.mkdir_p( version_output_folder ) unless File.directory?( version_output_folder )

        values_file = version_output_folder + "/values.jsn"

        File.open( values_file,"w" ) do |f|
          f.write( params[ 'prompt_data' ].to_s )
        end


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

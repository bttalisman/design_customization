class VersionsController < ApplicationController


    @@path_to_runner_script = Rails.root.to_s + "/bin/illustrator_processing/run_AI_script.rb"
    @@path_to_extract_script = Rails.root.to_s + "/bin/illustrator_processing/extractPrompts.jsx"
    @@path_to_search_replace_script = Rails.root.to_s + "/bin/illustrator_processing/searchAndReplace.jsx"


    @@versions_folder = Rails.root.to_s + "/public/system/versions/"


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
      @design_template_id = params['template_id']
    end


    def create

      @version = Version.new( version_params )

      @version.values = params[ 'prompt_data' ]

#      template_id = @version.design_template.id


      logger.info "VERSION_CONTROLLER - create"
#      logger.info "VERSION_CONTROLLER - create - template_id: " + template_id.to_s
      logger.info "VERSION_CONTROLLER - create - version_params: " + version_params.to_s
      logger.info "VERSION_CONTROLLER - create - version values: " + @version.values



      if @version.save

        # after we save, we can use the id to specify the output folder path.

        process_version

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




    def process_version


      version_output_folder = @@versions_folder + @version.id.to_s
      FileUtils.mkdir_p( version_output_folder ) unless File.directory?( version_output_folder )

      source_file = @version.design_template.original_file
      source_path = Rails.root.to_s + "/" + source_file.path
      source_folder = File.dirname( source_path )

      temp_values_file = source_folder + "/" + File.basename( source_file.path, '.ai' ) + "_data.jsn"


      # we'll create a temporary file containing necessary info, sitting right next to the
      # original ai file.

      File.open( temp_values_file, "w" ) do |f|
          f.write( @version.values.to_s )
      end


      # create a config file that tells run_AI_script what it needs

      config_file = version_output_folder + "/config_search_replace.jsn"

      config = {}
      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_search_replace_script
      config[ 'output folder' ] = version_output_folder

      File.open( config_file, "w" ) do |f|
        f.write( config.to_json )
      end


      # And run it!

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "VERSIONS_CONTROLLER - process_version - sys_com: " + sys_com.to_s

      system( sys_com )


    end



end

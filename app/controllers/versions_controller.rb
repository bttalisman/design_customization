class VersionsController < ApplicationController

    include ApplicationHelper

    @@path_to_runner_script = Rails.root.to_s + "/bin/illustrator_processing/run_AI_script.rb"
    @@path_to_extract_tags_script = Rails.root.to_s + "/bin/illustrator_processing/extractTags.jsx"
    @@path_to_extract_images_script = Rails.root.to_s + "/bin/illustrator_processing/extractImages.jsx"
    @@path_to_search_replace_script = Rails.root.to_s + "/bin/illustrator_processing/searchAndReplace.jsx"
    @@path_to_image_search_replace_script = Rails.root.to_s + "/bin/illustrator_processing/searchAndReplaceImages.jsx"


    @@versions_folder = Rails.root.to_s + "/public/system/versions/"


    def index
      @versions = Version.all
    end

    def edit
      @version = Version.find( params[ :id ] )
      @design_template = @version.design_template

      if( @design_template == nil ) then
        redirect_to versions_path, :notice => "The template for this version was deleted."
        return
      end

      @design_templates = DesignTemplate.all
      @design_template_id = @design_template.id
      @values = get_values_object( @version )
      @root_folder = Rails.root.to_s
    end


    def update
      @version = Version.find( params[ :id ] )
      @version.update( version_params )
      @version.values = params[ 'version_data' ]

      logger.info "VERSIONS_CONTROLLER - UPDATE - version_params: " + version_params.to_s
      logger.info "VERSIONS_CONTROLLER - UPDATE - params[ 'version_data' ]: " + params[ 'version_data' ].to_s

      if @version.save
        process_version
        redirect_to versions_path, :notice => "This version was saved."
      else
        render "new"
      end
    end


    def new
      @version = Version.new
      @design_templates = DesignTemplate.all
      @design_template_id = params['template_id']
      @root_folder = Rails.root.to_s
    end


    def create
      @version = Version.new( version_params )
      @version.values = params[ 'version_data' ]

      logger.info "VERSION_CONTROLLER - create"
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
      @root_folder = Rails.root.to_s

      @version_folder = get_version_folder( @version )
      @data_file = path_to_data_file( @design_template )

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


    def write_temp_data_file
      logger.info "VERSIONS_CONTROLLER - write_temp_data_file"
      temp_values_file = path_to_data_file( @version.design_template )

      # we'll create a temporary file containing necessary info, sitting right next to the
            # original ai file.
      File.open( temp_values_file, "w" ) do |f|
          f.write( @version.values.to_s )
      end
    end





    def run_tags_replace( config )

      logger.info "VERSIONS_CONTROLLER - run_tags_replace - config: " + config.to_s

      version_output_folder = get_version_folder( @version )


      source_file = @version.design_template.original_file
      source_path = source_file.path
      source_folder = File.dirname( source_path )

      write_temp_data_file

      # create a config file that tells run_AI_script what it needs
      config_file = version_output_folder + "/config_search_replace.jsn"

      File.open( config_file, "w" ) do |f|
        f.write( config.to_json )
      end

      # And run it!

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      runai = params[ 'runai' ]
      logger.info "VERSIONS_CONTROLLER - run_tags_replace - runai: " + runai.to_s

      if runai == 'on' then
        logger.info "VERSIONS_CONTROLLER - run_tags_replace - about to run sys_com: " + sys_com.to_s
        # run the ruby script. AI should generate output files to the output folder
        system( sys_com )
        logger.info "VERSIONS_CONTROLLER - run_tags_replace - output_folder_path: " + @version.output_folder_path

      end

    end




    def run_images_replace( config )

      logger.info "VERSIONS_CONTROLLER - run_images_replace - config: " + config.to_s

      version_output_folder = get_version_folder( @version )

      write_temp_data_file

      # create a config file that tells run_AI_script what it needs
      config_file = version_output_folder + "/config_image_search_replace.jsn"

      File.open( config_file, "w" ) do |f|
        f.write( config.to_json )
      end

      # And run it!

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      runai = params[ 'runai' ]
      logger.info "VERSIONS_CONTROLLER - run_images_replace - runai: " + runai.to_s

      if runai == 'on' then
        logger.info "VERSIONS_CONTROLLER - run_images_replace - about to run sys_com: " + sys_com.to_s
        # run the ruby script. AI should generate output files to the output folder
        system( sys_com )
        logger.info "VERSIONS_CONTROLLER - run_images_replace - output_folder_path: " + @version.output_folder_path
      end

    end



    def process_version

      # we're nothing without a template
      if @version.design_template == nil then
        return
      end



      config = {}
      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_search_replace_script
      config[ 'output folder' ] = version_output_folder

      run_tags_replace( config )


      config = {}
      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_image_search_replace_script
      config[ 'output folder' ] = version_output_folder

      run_images_replace( config )



      if( runai == 'on' ) then

        if( @version.output_folder_path != '' ) then

          logger.info "VERSIONS_CONTROLLER - process_version - About to copy to user's requested output folder."

          # copy these files to the user's requested output folder
          user_out_folder = Rails.root.to_s + "/" + @version.output_folder_path

          logger.info "VERSIONS_CONTROLLER - process_version - user_out_folder: " + user_out_folder.to_s

          FileUtils.mkdir_p( user_out_folder ) unless File.directory?( user_out_folder )

          wildcard = version_output_folder + "/*.ai"
          Dir.glob( wildcard ) { |f| FileUtils.cp File.expand_path(f), user_out_folder }

          wildcard = version_output_folder + "/*.jpg"
          Dir.glob( wildcard ) { |f| FileUtils.cp File.expand_path(f), user_out_folder }

        end # user has an output folder set

      end # runai is on

    end



end

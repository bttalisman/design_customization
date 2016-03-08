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


      # this is the prefix that the ui will append to any folder path specified by the user
      if( @version.output_folder_path == '' ) then
        @output_folder_base = @root_folder + '/'
      else
        @output_folder_base = ''
      end

    end


    def update
      @version = Version.find( params[ :id ] )
      @version.update( version_params )
      @version.values = params[ 'version_data' ]

      @design_template = @version.design_template
      # this is an array of tag names, extracted from the AI file
      @tags = get_tags_array( @design_template )
      # this is an array of image names, extracted from the AI file
      @images = get_images_array( @design_template )


      logger.info "VERSIONS_CONTROLLER - UPDATE - version_params: " + version_params.to_s
      logger.info "VERSIONS_CONTROLLER - UPDATE - params[ 'version_data' ]: " + params[ 'version_data' ].to_s
      logger.info "VERSIONS_CONTROLLER - UPDATE - @images: " + @images.to_s
      logger.info "VERSIONS_CONTROLLER - UPDATE - @tags: " + @tags.to_s


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

      @design_template = @version.design_template
      # this is an array of tag names, extracted from the AI file
      @tags = get_tags_array( @design_template )
      # this is an array of image names, extracted from the AI file
      @images = get_images_array( @design_template )

      logger.info "VERSION_CONTROLLER - create"
      logger.info "VERSION_CONTROLLER - create - version_params: " + version_params.to_s
      logger.info "VERSION_CONTROLLER - create - version values: " + @version.values.to_s
      logger.info "VERSION_CONTROLLER - create - @tags: " + @tags.to_s
      logger.info "VERSION_CONTROLLER - create - @images: " + @images.to_s



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
      @replacement_images = @version.replacement_images

      @version_folder = get_version_folder( @version )

      if( @design_template != nil ) then
        @data_file = path_to_data_file( @version.design_template.original_file.path )
      end

      logger.info "version_controller - show - @version: " + @version.to_s
      logger.info "version_controller - show - @design_template: " + @design_template.to_s
      logger.info "version_controller - show - @replacement_images: " + @replacement_images.to_s
      logger.info "version_controller - show - @replacement_images.length: " + @replacement_images.length.to_s


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



    # This method writes the current version's values string to a file sitting right
    # next to an AI file, named with _data.jsn.
    def write_temp_data_file( path_to_ai_file )
      logger.info "VERSIONS_CONTROLLER - write_temp_data_file - path_to_ai_file: " + path_to_ai_file.to_s

      temp_values_file = path_to_data_file( path_to_ai_file )

      # we'll create a temporary file containing necessary info, sitting right next to the
            # original ai file.
      File.open( temp_values_file, "w" ) do |f|
          f.write( @version.values.to_s )
      end
    end



    def do_run_ai( config )

      logger.info "VERSIONS_CONTROLLER - run_ai - config: " + config.to_s

      # this will put an appropriately named data file right next to the source file
      write_temp_data_file( config['source file'] )

      # create a config file that tells run_AI_script what it needs.  This file
      # can be anywhere, but we'll put it in the version folder
      version_output_folder = get_version_folder( @version )
      config_file = version_output_folder + "/config_ai.jsn"
      File.open( config_file, "w" ) do |f|
        f.write( config.to_json )
      end

      # And run it!

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "VERSIONS_CONTROLLER - run_ai - about to run sys_com: " + sys_com.to_s
      # run the ruby script. AI should generate output files to the output folder
      system( sys_com )

    end



    def process_version

      runai = params['runai']

      # bail out for any of these reasons
      if (@version.design_template == nil) then
        logger.info "VERSIONS_CONTROLLER - process_version - NOT PROCESSING, no template."
        return
      end
      if (runai != 'on') then
        logger.info "VERSIONS_CONTROLLER - process_version - NOT PROCESSING, runai not on."
        return
      end
      if ( (@images.length == 0) && (@tags.length == 0) ) then
        logger.info "VERSIONS_CONTROLLER - process_version - NOT PROCESSING, no images and no tags."
        return
      end


      original_file = @version.design_template.original_file
      original_file_path = original_file.path
      original_file_name = File.basename( original_file_path )
      original_file_base_name = File.basename( original_file_path, '.ai' )
      original_folder = File.dirname( original_file_path )

      version_folder = get_version_folder( @version )
      version_file_path = version_folder + '/' + original_file_name


      # copy the original file to the version folder, same name
      logger.info "VERSIONS_CONTROLLER - process_version - about to copy original file."
      FileUtils.cp( original_file_path, version_file_path )


      if( @version.output_folder_path != '' ) then
        # the user has specified an output folder
        logger.info "VERSIONS_CONTROLLER - process_version - user specified output folder."
        output_folder = @version.output_folder_path
      else
        # the user has not specified an output folder, we'll just use the version folder
        logger.info "VERSIONS_CONTROLLER - process_version - NO user specified output folder."
        output_folder = version_folder + '/'
      end

      intermediate_output = output_folder + original_file_base_name + '_mod.ai'


      logger.info "VERSIONS_CONTROLLER - process_version - output_folder: " + output_folder.to_s
      logger.info "VERSIONS_CONTROLLER - process_version - intermediate_output: " + intermediate_output.to_s

      int_file_exist = false


      if( @tags.length > 0 ) then
        # we should replace tags

        config = {}
        config[ 'source file' ] = version_file_path
        config[ 'script file' ] = @@path_to_search_replace_script
        config[ 'output folder' ] = output_folder

        do_run_ai( config )

        # unless something went wrong, this should exist
        int_file_exist = File.exist?( intermediate_output )
        logger.info "VERSIONS_CONTROLLER - process_version - int_file_exist: " + int_file_exist.to_s

      end # there are tags to replace


      if( @images.length > 0 ) then
        # we should replace images

        if( int_file_exist ) then
          config = {}
          config[ 'source file' ] = intermediate_output
          config[ 'script file' ] = @@path_to_image_search_replace_script
          config[ 'output folder' ] = output_folder
        else
          # the intermediate file does not exist, but we should still
          # replace images
          config = {}
          config[ 'source file' ] = version_file_path
          config[ 'script file' ] = @@path_to_image_search_replace_script
          config[ 'output folder' ] = output_folder
        end

        do_run_ai( config )

      end # there are images to replace

    end



end

class DesignTemplatesController < ApplicationController

    include ApplicationHelper
    include DesignTemplatesHelper


    @@path_to_runner_script = Rails.root.to_s + "/bin/illustrator_processing/run_AI_script.rb"
    @@path_to_extract_tags_script = Rails.root.to_s + "/bin/illustrator_processing/extractTags.jsx"
    @@path_to_extract_images_script = Rails.root.to_s + "/bin/illustrator_processing/extractImages.jsx"
    @@path_to_search_replace_script = Rails.root.to_s + "/bin/illustrator_processing/searchAndReplace.jsx"


    def index
      templates = DesignTemplate.all
      @design_templates = Array.new

      templates.each { |t|
        o = { :name => t.name.to_s,
          :tags => has_tags?( t ).to_s,
          :images => has_images?( t ).to_s,
          :id => t.id.to_s,
          :created => t.created_at.to_s
        }
        @design_templates << o
      }
    end


    def show
      @design_template = DesignTemplate.find( params[ :id ] )
      @versions = @design_template.versions

      file = @design_template.original_file
      if( file.path != nil ) then
        source_path = file.path
        @folder = File.dirname( source_path.to_s )
      end

      @quick_new_partial_url = get_local_host + '/partials/quick_new?template_id=' + @design_template.id.to_s
    end



    def edit

      logger.info "DESIGN_TEMPLATES_CONTROLLER - edit! - params: " + params.to_s
      @design_template = DesignTemplate.find( params[ :id ] )

      # this is an array of tag names, extracted from the AI file
      @tags = get_tags_array( @design_template )
      # this is an array of image names, extracted from the AI file
      @images = get_images_array( @design_template )

    end


    def update

      logger.info "DESIGN_TEMPLATES_CONTROLLER - update! - params: " + params.to_s

      @design_template = DesignTemplate.find( params[ :id ] )
      @design_template.update( design_template_params )

      logger.info "DESIGN_TEMPLATES_CONTROLLER - update - about to save."
      if @design_template.save
        logger.info "DESIGN_TEMPLATES_CONTROLLER - update - SUCCESS!"
        redirect_to design_template_path, :notice => "This template was saved."
      else
        logger.info "DESIGN_TEMPLATES_CONTROLLER - update - FAILURE!"
        render "new"
      end
    end



    # this action executes in response to an ajax call from the Design Template
    # editor, the body of the post made contains JSON describing all extensible
    # settings
    def all_settings

      logger.info "DESIGN_TEMPLATES_CONTROLLER - ALL_SETTINGS!!!!!!!!!!"

      #  expecting something like { 'extracted_settings' => arbitrary settings depending on tags,
      #  'general_settings' => settings every DesignTemplate has }
      myHashString = request.body.read.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - all_settings! - myHashString: " + myHashString

      if( is_json?( myHashString ) ) then
        logger.info "DESIGN_TEMPLATES_CONTROLLER - all_settings! - good JSON!"
        myHash = JSON.parse myHashString
      else
        logger.info "DESIGN_TEMPLATES_CONTROLLER - all_settings! - BAD JSON!"
      end

      extractedObject = myHash[ 'extracted_settings' ]
      extractedString = extractedObject.to_json

      @design_template = DesignTemplate.find( params[ :id ] )
      @design_template.prompts = extractedString

      @design_template.name = myHash[ 'general_settings' ][ 'template_name' ]

      if @design_template.save
        logger.info "DESIGN_TEMPLATES_CONTROLLER - all_settings - SUCCESS!"
      else
        logger.info "DESIGN_TEMPLATES_CONTROLLER - all_settings - FAILURE!"
      end

      render nothing: true

    end

    def new
      @design_template = DesignTemplate.new
    end


    def create

      logger.info "DESIGN_TEMPLATES_CONTROLLER - create!"

      @design_template = DesignTemplate.new( design_template_params )

      stayAfterSave = params['stayAfterSave']
      logger.info "DESIGN_TEMPLATES_CONTROLLER - create - design_template_params: " + design_template_params.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - create - stayAfterSave: " + stayAfterSave

      if @design_template.save

        logger.info "DESIGN_TEMPLATES_CONTROLLER - create - SUCCESS! About to procdess the AI file."
        process_original

        if( stayAfterSave == 'true') then
          # This action was called because the user wants to edit the extracted settings
          # We've got to save and process first.
          redirect_to action: 'edit', :notice => "Set your prefs!", :id => @design_template.id
        else
          redirect_to design_templates_path, :notice => "This template was saved."
        end

      else

        logger.info "DESIGN_TEMPLATES_CONTROLLER - create - FAILURE!"
        render "new"

      end

    end


    def force_process
      logger.info "DESIGN_TEMPLATES_CONTROLLER - force_process"
      @design_template = DesignTemplate.find( params[ :id ] )
      process_original
      redirect_to @design_template, :notice => "This template was processed."
    end


    def delete_all
      logger.info 'DESIGN_TEMPLATES_CONTROLLER - delete_all'

      dts = DesignTemplate.all
      dts.each { |d|
        d.delete
      }
      render nothing: true
    end


    def destroy
      logger.info "DESIGN_TEMPLATES_CONTROLLER - destroy"
      @design_template = DesignTemplate.find( params[ :id ] )
      @design_template.destroy
      redirect_to :design_templates
    end



    private


    def process_original
      extract_tags
      extract_images
    end


    def extract_tags

      file = @design_template.original_file
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_tags - file: " + file.to_s

      source_path = file.path
      source_folder = File.dirname( source_path )
      config_file = source_folder + "/config_extract_tags.jsn"

      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_tags - source_path: " + source_path.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_tags - config_file: " + config_file.to_s

      config = {}


      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_extract_tags_script
      config[ 'output folder' ] = source_folder   # the prompts file goes right next to the original file

      File.open( config_file,"w" ) do |f|
        f.write( config.to_json )
      end

      # the illustrator scripts place all output
      # in a subfolder of the folder containing the original file, and later
      # moved to wherever
      ai_output_folder = source_folder + "/output"
      FileUtils.mkdir_p( ai_output_folder ) unless File.directory?( ai_output_folder )

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_tags - sys_com: " + sys_com.to_s

      results = system( sys_com )
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_tags - results: " + results.to_s

    end


    def extract_images

      file = @design_template.original_file
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_images - file: " + file.to_s

      source_path = file.path
      source_folder = File.dirname( source_path )
      config_file = source_folder + "/config_extract_images.jsn"

      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_images - source_path: " + source_path.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_images - config_file: " + config_file.to_s

      config = {}


      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_extract_images_script
      config[ 'output folder' ] = source_folder   # the prompts file goes right next to the original file

      File.open( config_file,"w" ) do |f|
        f.write( config.to_json )
      end

      # the illustrator scripts place all output
      # in a subfolder of the folder containing the original file, and later
      # moved to wherever
      ai_output_folder = source_folder + "/output"
      FileUtils.mkdir_p( ai_output_folder ) unless File.directory?( ai_output_folder )

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_images - sys_com: " + sys_com.to_s

      results = system( sys_com )
      logger.info "DESIGN_TEMPLATES_CONTROLLER - extract_images - results: " + results.to_s

    end





    def design_template_params
         params.require( :design_template ).permit( :orig_file_path, :name, :tags, :original_file )
    end

end

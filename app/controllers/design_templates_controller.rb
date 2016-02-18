class DesignTemplatesController < ApplicationController

    include ApplicationHelper


    @@path_to_runner_script = Rails.root.to_s + "/bin/illustrator_processing/run_AI_script.rb"
    @@path_to_extract_script = Rails.root.to_s + "/bin/illustrator_processing/extractTags.jsx"
    @@path_to_search_replace_script = Rails.root.to_s + "/bin/illustrator_processing/searchAndReplace.jsx"


    def index
      @design_templates = DesignTemplate.all
    end

    def show
      @design_template = DesignTemplate.find( params[ :id ] )
      @versions = @design_template.versions

      file = @design_template.original_file
      source_path = file.path

      @folder = File.dirname( source_path.to_s )

    end





    def edit

      @design_template = DesignTemplate.find( params[ :id ] )
      @tags = get_tags_array( @design_template )

    end


    def update

      logger.info "DESIGN_TEMPLATES_CONTROLLER - update! - params: " + params.to_s





      myHashString = request.body.read.to_s
      myHash = JSON.parse myHashString
      logger.info "DESIGN_TEMPLATES_CONTROLLER - update! - myHashString: " + myHashString



      @design_template = DesignTemplate.find( params[ :id ] )
      @design_template.update( design_template_params )

      @design_template.prompts = myHashString

      logger.info "DESIGN_TEMPLATES_CONTROLLER - update - about to save."
      if @design_template.save
        logger.info "DESIGN_TEMPLATES_CONTROLLER - update - SUCCESS!"
        redirect_to design_template_path, :notice => "This template was saved."
      else
        logger.info "DESIGN_TEMPLATES_CONTROLLER - update - FAILURE!"
        render "new"
      end
    end




    def new
      @design_template = DesignTemplate.new
    end


    def create
      @design_template = DesignTemplate.new( design_template_params )

      stayAfterSave = params['stayAfterSave']
      logger.info "DESIGN_TEMPLATES_CONTROLLER - create - stayAfterSave: " + stayAfterSave

      if @design_template.save

        logger.info "DESIGN_TEMPLATES_CONTROLLER - create - SUCCESS!"
        process_original

        if( stayAfterSave == 'true') then
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


    def destroy

      logger.info "DESIGN_TEMPLATES_CONTROLLER - destroy"
      @design_template = DesignTemplate.find( params[ :id ] )

      @design_template.destroy

      redirect_to :design_templates

    end



    private




    def process_original

      file = @design_template.original_file
      source_path = Rails.root.to_s + "/" + file.path

      source_folder = File.dirname( source_path )
      config_file = source_folder + "/config_extract_tags.jsn"

      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - source_path: " + source_path.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - config_file: " + config_file.to_s


      config = {}
      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_extract_script
      config[ 'output folder' ] = source_folder   # the prompts file goes right next to the original file


      File.open( config_file,"w" ) do |f|
        f.write( config.to_json )
      end

      # the illustrator scripts dont get much in the way of input, so all output
      # is placed in a subfolder of the folder containing the original file, and later
      # moved to wherever
      ai_output_folder = source_folder + "/output"
      FileUtils.mkdir_p( ai_output_folder ) unless File.directory?( ai_output_folder )

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - sys_com: " + sys_com.to_s

      system( sys_com )

    end





    def design_template_params
         params.permit( :orig_file_path, :design_template, :name, :tags, :original_file )
    end

end

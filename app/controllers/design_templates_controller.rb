class DesignTemplatesController < ApplicationController


    @@path_to_runner_script = Rails.root.to_s + "/bin/illustrator_processing/run_AI_script.rb"
    @@path_to_extract_script = Rails.root.to_s + "/bin/illustrator_processing/extractPrompts.jsx"
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
    end

    def update
      @design_template = DesignTemplate.find( params[ :id ] )
      @design_template.update( design_template_params )

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

      if @design_template.save
        logger.info "DESIGN_TEMPLATES_CONTROLLER - create - SUCCESS!"
        process_original
        redirect_to design_templates_path, :notice => "This template was saved."
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

    def process_original

      file = @design_template.original_file
      source_path = Rails.root.to_s + "/" + file.path

      folder = File.dirname( source_path )
      config_file = folder + "/config_extract_prompts.jsn"

      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - source_path: " + source_path.to_s
      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - config_file: " + config_file.to_s

      config = {}
      config[ 'source file' ] = source_path
      config[ 'script file' ] = @@path_to_extract_script
      config[ 'output folder' ] = folder



      File.open( config_file,"w" ) do |f|
        f.write( config.to_json )
      end

      ai_output_folder = folder + "/output"
      FileUtils.mkdir_p( ai_output_folder ) unless File.directory?( ai_output_folder )

      sys_com = "ruby " + @@path_to_runner_script + " '" + config_file + "'"
      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - sys_com: " + sys_com.to_s

      system( sys_com )


    end




    def destroy

      logger.info "DESIGN_TEMPLATES_CONTROLLER - destroy"
      @design_template = DesignTemplate.find( params[ :id ] )

      @design_template.destroy

      redirect_to :design_templates

    end





    def design_template_params
         params.require(:design_template).permit( :orig_file_path, :name, :prompts, :original_file )
    end

end

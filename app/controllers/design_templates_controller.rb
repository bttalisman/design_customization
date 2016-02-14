class DesignTemplatesController < ApplicationController


    def index
      @design_templates = DesignTemplate.all
    end

    def show
      @design_template = DesignTemplate.find( params[ :id ] )
      @versions = @design_template.versions
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

    def process_original

      file = @design_template.original_file
      source_path = file.path

      logger.info "DESIGN_TEMPLATES_CONTROLLER - process_original - source_path: " + source_path.to_s

      config = {}
      config[ 'source file' ] = source_path


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

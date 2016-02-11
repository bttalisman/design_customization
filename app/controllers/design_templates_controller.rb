class DesignTemplatesController < ApplicationController


    def index
      @design_templates = DesignTemplate.all
    end

    def edit
      @design_template = DesignTemplate.find( params[ :id ] )
    end

    def create
    end

    def new
      @design_template = DesignTemplate.new

    end

    def update
    end

    def show
      @design_template = DesignTemplate.find( params[ :id ] )
    end

    def destroy
    end

    def design_template_params
         params.require(:design_template).permit( :orig_file_path, :name, :prompts )
    end

end

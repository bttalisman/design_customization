class VersionsController < ApplicationController

    def index
      @versions = Version.all
    end

    def edit
    end

    def create
    end

    def new
      @version = Version.new
      @templates = Template.all

    end

    def update
    end

    def show
    end

    def destroy
    end


    def version_params
       params.require(:version).permit( :output_folder_path, :values, :template_id )
    end



end

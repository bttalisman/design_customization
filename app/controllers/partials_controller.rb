class PartialsController < ApplicationController

  include ApplicationHelper

  layout 'partials'


  def tags

    template_id = params[ :id ]
    @design_template = DesignTemplate.find( template_id )
    @tags = get_tags_array( @design_template )


    logger.info "PARTIALS_CONTROLLER - tags - template_id: " + template_id.to_s

  end




  def values


    id = params[ :id ]
    logger.info "PARTIALS_CONTROLLER - values - id: " + id.to_s

    version_id = params[ :version_id ]
    logger.info "PARTIALS_CONTROLLER - values - version_id: " + version_id.to_s


    @design_template = DesignTemplate.find( id )

    if( version_id != nil ) then
      version = Version.find( version_id )
    end

    if( version != nil ) then

      values_string = version.values

      if( values_string != nil ) then

        @values = JSON.parse( values_string )

      end

    end


    file = @design_template.original_file
    source_path = file.path

    @folder = Rails.root.to_s + "/" + File.dirname( source_path.to_s )

    # get the file name, remove the .ai
    @orig_file_name = File.basename( source_path.to_s, '.ai' )
    @tags_file = @folder + "/" + @orig_file_name + "_tags.jsn"
    @tags_file_exist = File.exist?( @tags_file )

    tags_string = ''
    @tags = nil

    if @tags_file_exist then

      File.open( @tags_file,"r" ) do |f|
        tags_string = f.read()
      end

      @tags = JSON.parse( tags_string )

      logger.info "PARTIALS_CONTROLLER - values - @tags: " + @tags.to_s

    end

  end

end

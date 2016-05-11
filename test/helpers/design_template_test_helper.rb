# DesignTemplate Test Helper
module DesignTemplateTestHelper

  # Add the ai file to the DesignTemplate, build the necessary folder
  # structure, and launch the extracting process.
  def process_template( design_template, file_name )
    file = sample_file( file_name )
    design_template.orig_file_path = file.path.to_s
    design_template.original_file = file
    design_template.original_file.\
      instance_write(:content_type, 'application/postscript')
    build_test_template( design_template, file )

    if design_template.save!
      Rails.logger.info 'design_template_test_helper - process_template() - successful save'
      process_original( design_template )
    else
      Rails.logger.info 'design_template_test_helper - process_template() - FAILED to save.'
    end
  end

  # DesignTemplates created in test environment need to create their own
  # folder structure, I guess because paperclip doesn't do it.
  def build_test_template( design_template, file )
    Rails.logger.info 'design_template_test_helper - build_test_template()'\
      + ' design_template: ' + design_template.to_s

    orig_path = design_template.original_file.path.to_s
    Rails.logger.info 'design_template_test_helper - build_test_template()'\
      + ' orig_path: ' + orig_path

    make_output_folder( design_template )
    FileUtils.cp( file.path.to_s, orig_path )
  end

  #####################################################################
  # Helper functions for setting up DesignTemplate.prompts
  #
  # This method returns an object providing arbitrary values for all of the
  # DesignTemplate's extracted images and tags.
  def get_some_extracted_settings( design_template )
    tags = get_tags_array( design_template )
    images = get_images_array( design_template )

    tag_settings = get_some_tag_settings( tags )
    image_settings = get_some_image_settings( images )

    extracted_settings = { 'tag_settings' => tag_settings,
                           'image_settings' => image_settings }
    extracted_settings
  end

  def get_some_image_settings( images )
    image_settings = {}
    images.each { |i|
      o = { 'replace_image' => 'checked' }
      image_settings[ i ] = o
    }
    image_settings
  end

  def get_some_tag_settings( tags )
    tag_settings = {}
    tags.each { |t|
      o = { 'prompt' => 'Enter Stuff',
            'max_length' => '33',
            'min_length' => '22',
            'pick_color' => 'checked',
            'use_pallette' => 'checked',
            'palette_id' => '4' }
      tag_settings[ t ] = o
    }
    tag_settings
  end
end

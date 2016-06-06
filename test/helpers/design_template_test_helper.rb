# DesignTemplate Test Helper
module DesignTemplateTestHelper
  # This method takes a file name and does all the stuff that needs to be
  # done to set up a design_template, ready to be used to create a version.
  #
  # returns - { 'design_template' => DesignTemplate,
  #             'images' => array of image names,
  #             'tags' => array of tag names,
  #             'stats' => object describing template statistics/status }
  def get_template_package( file_name )
    design_template = DesignTemplate.new
    design_template.save
    dt_id = design_template.id

    process_template( design_template, file_name )

    tags = get_tags_array( design_template )
    images = get_images_array( design_template )
    stats = get_stats( design_template )
    extracted_settings = get_some_extracted_settings( design_template )
    general_settings = {}

    o = { 'extracted_settings' => extracted_settings,
          'general_settings' => general_settings }

    raw_post( action: :all_settings,
              controller: DesignTemplatesController.new,
              params: { 'id' => dt_id },
              body: o.to_json )

    # Apparently, the object is copied or something, I have no idea, you need
    # to find it again or it doesn't reflect all of the changes made above.
    design_template = DesignTemplate.find( dt_id )
    package = { 'design_template' => design_template,
                'tags' => tags,
                'images' => images,
                'stats' => stats }
    package
  end

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
      assert( false, 'DesignTemplate save failed.' )
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

  # This method returns an object providing arbitrary values for all of the
  # DesignTemplate's extracted images and tags.
  def get_some_extracted_settings( design_template )
    tags = get_tags_array( design_template )
    images = get_images_array( design_template )

    tag_settings = get_some_tag_settings( tags )
    image_settings = get_some_image_settings( images )

    extracted_settings = { PROMPTS_KEY_TAG_SETTINGS => tag_settings,
                           PROMPTS_KEY_IMAGE_SETTINGS => image_settings }
    extracted_settings
  end

  def get_some_image_settings( images )
    image_settings = {}
    images.each do |i|
      o = { 'replace_image' => 'checked' }
      image_settings[ i ] = o
    end
    image_settings
  end

  def get_some_tag_settings( tags )
    tag_settings = {}
    tags.each do |t|
      o = { 'prompt' => 'Enter Stuff',
            'max_length' => '33',
            'min_length' => '22',
            'pick_color' => 'checked',
            'use_palette' => 'checked',
            'palette_id' => random_palette.id }
      tag_settings[ t ] = o
    end
    tag_settings
  end
end

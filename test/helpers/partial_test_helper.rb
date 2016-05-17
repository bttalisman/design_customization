# Partial Test Helper
module PartialTestHelper

  # images and tags should be arrays representing the images and tags
  # extracted from an ai file.  Values should be json providing all necessary
  # data for the version UI to present to the customer.
  def assert_valid_values( images, tags, values )

    Rails.logger.info 'PartialTestHelper - valid_values? - images: ' + images.to_s
    Rails.logger.info 'PartialTestHelper - valid_values? - tags: ' + tags.to_s
    Rails.logger.info 'PartialTestHelper - valid_values? - values: ' + values.to_s

    image_values = values[ 'image_settings' ]
    tag_values = values[ 'tag_settings' ]

    images.each { |i|
      assert_not_empty( image_values[ i ], 'Missing image value.' )
    }

    tags.each { |t|
      assert_not_empty( tag_values[ t ], 'Missing tag value.' )
    }
  end

  def exercise_settings( file_name )
    # Create a new template with a single tag and a single image
    dt = DesignTemplate.new
    dt.save
    dt_id = dt.id
    process_template( dt, file_name )
    get( 'design_template_settings', id: dt_id )
    assert_response :success
    extracted_tags = assigns( :tags )
    extracted_images = assigns( :images )

    # Get some settings based on the DesignTemplate
    extracted_settings = get_some_extracted_settings( dt ) # get some dummy data
    general_settings = {}
    o = { 'extracted_settings' => extracted_settings,
          'general_settings' => general_settings }
    # Set values for the extrated settings.
    raw_post( action: :all_settings,
              controller: DesignTemplatesController.new,
              params: { 'id' => dt_id },
              body: o.to_json )

    get( 'design_template_settings', id: dt_id )
    assert_response :success
    values = assigns( :values )
    assert_valid_values( extracted_images, extracted_tags, values )
  end

end

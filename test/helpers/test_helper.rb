# Test Helper
module TestHelper
  def sample_file(filename = 'one_tag_one_image.ai')
    s = 'test/fixtures/original_files/' + filename
    File.new(s)
  end

  def raw_post(action, params, body)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, params)
    @request.env.delete('RAW_POST_DATA')
    response
  end

  def process_template( design_template, file_name )
    file = sample_file( file_name )
    design_template.orig_file_path = file.path.to_s
    design_template.original_file = file
    design_template.original_file.\
      instance_write(:content_type, 'application/postscript')
    build_test_template( design_template, file )

    if design_template.save!
      Rails.logger.info 'test_helper - process_template() - successful save'
      process_original( design_template )
    else
      Rails.logger.info 'test_helper - process_template() - failed save'
    end
  end

  # DesignTemplates created in test environment need to create their own
  # folder structure, I guess because paperclip doesn't do it.
  def build_test_template( design_template, file )
    Rails.logger.info 'test_helper - build_test_template()'\
      + ' design_template: ' + design_template.to_s


    orig_path = design_template.original_file.path.to_s
    Rails.logger.info 'test_helper - build_test_template()'\
      + ' orig_path: ' + orig_path

    make_output_folder( design_template )
    FileUtils.cp( file.path.to_s, orig_path )

  end

end

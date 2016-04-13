# ReplacementImages Controller
class ReplacementImagesController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
  end

  def replacement_image_params
    params.require( :replacement_image ).permit( :uploaded_file )
  end
end

class CollagesController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
  end

  private

  def collage_params
    params.require( :collage ).permit( )
  end
end

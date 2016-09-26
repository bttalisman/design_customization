# Users Controller
class UsersController < ApplicationController

  def index
    users = User.all
    @users = []

    users.each do |u|
      o = { first_name: u.first_name.to_s,
            last_name: u.last_name.to_s,
            shopify_id: u.shopify_id.to_s,
            email: u.email.to_s
      }
      @users << o
    end

    Rails.logger.info 'users_controller - index() - @users.length: '\
      + @users.length.to_s
  end

  def show

  end

  def edit
  end

  def update
  end

  def new
  end

  def create
  end

  def destroy
  end

  def delete_all
  end

  def user_params
    params.require( :user ).permit( :first_name, :last_name, :shopify_id, :email )
  end
end

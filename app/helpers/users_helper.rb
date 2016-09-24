# Users Helper
module UsersHelper


  def get_full_name( id )
    return '' if id.nil?
    u = User.find( id )
    full_name = u.last_name + ', ' + u.first_name
    full_name
  end
end

# Color Model
class Color < ActiveRecord::Base
  has_and_belongs_to_many :palettes
end

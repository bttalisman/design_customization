# Palette Model
class Palette < ActiveRecord::Base
  has_and_belongs_to_many :colors
end

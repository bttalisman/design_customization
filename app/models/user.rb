class User < ActiveRecord::Base
  has_many :versions, dependent: :destroy
  has_many :design_templates, dependent: :destroy
end

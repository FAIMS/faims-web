class UserModule < ActiveRecord::Base
  belongs_to :user
  belongs_to :project_module
  attr_accessible :password
end

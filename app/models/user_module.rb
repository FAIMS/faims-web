class UserModule < ActiveRecord::Base
  belongs_to :user
  belongs_to :project_module

  attr_accessible :user_id, :project_module_id
end

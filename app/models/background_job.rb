class BackgroundJob < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :project_exporter
  belongs_to :user
  attr_accessible :job_type, :module_name, :status
end

class ProjectModuleProcess < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :background_job

  attr_accessible :project_module, :processor, :options, :action, :uuid
end

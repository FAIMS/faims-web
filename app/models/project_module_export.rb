class ProjectModuleExport < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :background_job

  attr_accessible :project_module, :exporter, :options, :uuid
end

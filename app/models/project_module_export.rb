class ProjectModuleExport < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :background_job
  has_many :project_module_export_options

  attr_accessible :project_module, :exporter, :options, :uuid
end

class BackgroundJob < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :project_exporter
  belongs_to :delayed_job, :class_name => '::Delayed::Job'
  belongs_to :user
  has_one :project_module_exports
  attr_accessible :job_type, :module_name, :status, :project_module, :delayed_job
  default_scope order: 'updated_at DESC'
  validates_presence_of :job_type, :module_name, :status
end

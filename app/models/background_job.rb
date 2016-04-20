class BackgroundJob < ActiveRecord::Base
  belongs_to :project_module
  belongs_to :project_exporter
  belongs_to :delayed_job, :class_name => '::Delayed::Job'
  belongs_to :user
  attr_accessible :job_type, :module_name, :status
  default_scope order: 'updated_at DESC'
end

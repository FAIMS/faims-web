class AddProjectProcessorToBackgroundJobs < ActiveRecord::Migration
  def change
    add_column :background_jobs, :project_processor_id, :integer
    add_index :background_jobs, :project_processor_id
  end
end

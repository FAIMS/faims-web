class CreateBackgroundJobs < ActiveRecord::Migration
  def change
    create_table :background_jobs do |t|
      t.string :status
      t.references :project_module
      t.references :project_exporter
      t.string :job_type
      t.references :user
      t.string :module_name
      t.references :delayed_job

      t.timestamps
    end
    add_index :background_jobs, :project_module_id
    add_index :background_jobs, :project_exporter_id
    add_index :background_jobs, :user_id
  end
end

class CreateProjectModuleProcessors < ActiveRecord::Migration
  def change
    create_table :project_module_processes do |t|
      t.references :project_module
      t.string :processor
      t.text :options
      t.text :action
      t.references :background_job
      t.text :uuid

      t.timestamps
    end
    add_index :project_module_processes, :project_module_id
    add_index :project_module_processes, :processor
    add_index :project_module_processes, :options
    add_index :project_module_processes, :background_job_id
  end
end

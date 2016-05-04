class CreateProjectModuleExports < ActiveRecord::Migration
  def change
    create_table :project_module_exports do |t|
      t.references :project_module
      t.string :exporter
      t.text :options
      t.references :background_job
      t.text :uuid

      t.timestamps
    end
    add_index :project_module_exports, :project_module_id
    add_index :project_module_exports, :exporter
    add_index :project_module_exports, :options
    add_index :project_module_exports, :background_job_id
  end
end

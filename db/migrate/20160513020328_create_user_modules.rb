class CreateUserModules < ActiveRecord::Migration
  def change
    create_table :user_modules do |t|
      t.references :user
      t.references :project_module
      t.text :password

      t.timestamps
    end
    add_index :user_modules, :user_id
    add_index :user_modules, :project_module_id
  end
end

class MoveModulePasswordToUser < ActiveRecord::Migration
  def up
    add_column :users, :module_password, :text
    remove_column :user_modules, :password
  end

  def down
    add_column :user_modules, :password, :text
    remove_column :users, :module_password
  end
end

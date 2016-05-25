class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :new, :to => :create
    alias_action :edit_details, :update_details, :change_password, :save_password, :to => :edit_user
    alias_action :index, :show, :to => :read

    if user
      can [:read], User
      can [:manage], ProjectModule
      if user.admin?
        can [:read, :create, :delete, :update], ProjectExporter
        can [:edit_role, :update_role, :edit_user, :create, :destroy, :activate, :deactivate], User
      else
        cannot [:delete_project_module], ProjectModule
        can [:edit_user], User do |u|
          user == u
        end
      end
    end
  end

end

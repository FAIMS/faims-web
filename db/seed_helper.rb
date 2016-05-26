def create_roles_and_users
  Role.delete_all
  User.delete_all

  Role.create!(:name => 'superuser')
  Role.create!(:name => 'user')

  # A superuser
  create_user(first_name: 'Faims',
              last_name: 'Admin',
              email: 'faimsadmin@intersect.org.au',
              password: 'Pass.123')
  set_role('faimsadmin@intersect.org.au', 'superuser')

  # A non-superuser
  create_user(first_name: 'Faims'
              last_name: 'User',
              email: 'user@faims.org.au',
              password: 'Pass.123')
  set_role('user@faims.org.au', 'user')
end

def set_role(email, role)
  user = User.where(:email => email).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_user(attrs)
  u = User.new(attrs)
  u.activate
  u.save!
end
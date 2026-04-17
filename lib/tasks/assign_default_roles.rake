namespace :users do
  desc "Assign default 'member' role to all existing users without any role"
  task assign_default_roles: :environment do
    # Ensure all roles exist
    role_names = %w[superadmin admin account_manager data_manager member]
    role_names.each do |role_name|
      Role.find_or_create_by!(name: role_name)
    end
    puts "Roles ensured: #{role_names.join(', ')}"

    # Find users without any role
    users_without_roles = User.left_joins(:roles).where(roles: { id: nil })
    count = users_without_roles.count
    puts "Found #{count} users without roles"

    users_without_roles.find_each do |user|
      user.add_role(:member)
      puts "  Assigned 'member' to #{user.email}"
    end

    puts "Done. Assigned 'member' role to #{count} users."
    puts "Users still without roles: #{User.left_joins(:roles).where(roles: { id: nil }).count}"
  end
end

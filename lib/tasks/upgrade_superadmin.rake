namespace :users do
  desc "Upgrade admin@aqvc.com to superadmin role"
  task upgrade_superadmin: :environment do
    email = "admin@aqvc.com"
    role_name = "superadmin"

    Role.find_or_create_by!(name: role_name)

    user = User.find_by(email: email)
    if user.nil?
      puts "User with email #{email} not found."
      exit 1
    end

    if user.has_role?(:superadmin)
      puts "#{email} already has the superadmin role."
    else
      user.roles = []
      user.add_role(:superadmin)
      puts "Upgraded #{email} to superadmin."
    end
  end
end

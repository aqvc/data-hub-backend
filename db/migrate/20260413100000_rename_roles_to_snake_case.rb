class RenameRolesToSnakeCase < ActiveRecord::Migration[7.0]
  RENAMES = {
    "Admin" => "admin",
    "AccountManager" => "account_manager",
    "DataManager" => "data_manager",
    "Member" => "member"
  }.freeze

  def up
    RENAMES.each do |old_name, new_name|
      execute("UPDATE roles SET name = '#{new_name}', normalized_name = '#{new_name.upcase}' WHERE name = '#{old_name}'")
    end
  end

  def down
    RENAMES.each do |old_name, new_name|
      execute("UPDATE roles SET name = '#{old_name}', normalized_name = '#{old_name.upcase}' WHERE name = '#{new_name}'")
    end
  end
end

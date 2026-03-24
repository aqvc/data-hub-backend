class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :role_claims

end

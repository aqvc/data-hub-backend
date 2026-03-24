class RefreshToken < ApplicationRecord
  self.table_name = "user_refresh_tokens"

  belongs_to :user

end

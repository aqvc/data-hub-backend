class UserDetail < ApplicationRecord

  self.table_name = "public.user_details_hub"

  belongs_to :user, foreign_key: :id, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

end

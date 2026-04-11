class Event < ApplicationRecord

  acts_as_paranoid

  belongs_to :investor, optional: true

end

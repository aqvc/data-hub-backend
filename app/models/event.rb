class Event < ApplicationRecord

  belongs_to :investor, optional: true

end

class InvestorCurrency < ApplicationRecord

  belongs_to :currency
  belongs_to :investor

end

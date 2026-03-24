module Types
  class SortInputType < Types::BaseInputObject
    argument :field, String, required: false
    argument :direction, String, required: false
  end
end

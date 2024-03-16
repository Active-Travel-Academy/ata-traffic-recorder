class Journey < ApplicationRecord
  self.inheritance_column = nil # type is used by the R program asker
  belongs_to :ltn
end

class Item < ApplicationRecord
  validates_numericality_of :stock_quantity, greater_than_or_equal_to: 0
end

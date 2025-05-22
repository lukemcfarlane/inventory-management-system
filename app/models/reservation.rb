class Reservation < ApplicationRecord
  belongs_to :worker
  belongs_to :item
end

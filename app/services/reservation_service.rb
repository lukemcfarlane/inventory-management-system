# frozen_string_literal: true

class ReservationService
  def initialize(item_id:, worker_id: , quantity: 5)
    @item_id = item_id
    @worker_id = worker_id
    @quantity = quantity
  end

  def call
    create_reservation!
  end

  private

  attr_reader :item_id, :worker_id, :quantity

  def create_reservation!
    Reservation.create!(
      worker_id: worker_id,
      item_id: item_id,
      quantity: quantity,
    )

    item.update!(stock_quantity: item.stock_quantity - quantity)
  end

  def item
    Item.find(item_id)
  end
end

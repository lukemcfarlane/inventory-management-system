# frozen_string_literal: true

class ReservationService
  def initialize(item_id:, worker_id: , quantity: 5)
    @item_id = item_id
    @worker_id = worker_id
    @quantity = quantity
  end

  def call
    raise NotImplementedError.new
  end

  private

  attr_reader :item_id, :worker_id, :quantity
end

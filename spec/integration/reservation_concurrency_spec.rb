require 'rails_helper'

RSpec.describe 'Concurrent Reservations', type: :integration do
  let!(:item) { Item.create!(name: 'Gadget', stock_quantity: 10) }
  let!(:worker1) { Worker.create!(name: 'Alice') }
  let!(:worker2) { Worker.create!(name: 'Bob') }

  before do
    Reservation.delete_all
  end

  def run_in_thread(&block)
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection(&block)
    end
  end

  it 'does not oversell stock when two workers reserve at once' do
    pending 'not implemented'

    threads = []

    threads << run_in_thread do
      ReservationService.new(item_id: item.id, worker_id: worker1.id, quantity: 7).call
    end

    threads << run_in_thread do
      ReservationService.new(item_id: item.id, worker_id: worker2.id, quantity: 7).call
    end

    threads.each(&:join)

    total_reserved = Reservation.sum(:quantity)
    expect(total_reserved).to be <= 10

    item.reload
    expect(item.stock_quantity).to eq(10 - total_reserved)
  end

  it 'records one success and one failure if both try to over-reserve' do
    pending 'not implemented'

    results = []

    threads = []

    threads << run_in_thread do
      results << ReservationService.new(item_id: item.id, worker_id: worker1.id, quantity: 7).call
    end

    threads << run_in_thread do
      results << ReservationService.new(item_id: item.id, worker_id: worker2.id, quantity: 7).call
    end

    threads.each(&:join)

    expect(results.count(true)).to eq(1)
    expect(results.count(false)).to eq(1)

    total_reserved = Reservation.sum(:quantity)
    expect(total_reserved).to eq(7)
  end

  it 'allows multiple sequential reservations until stock runs out' do
    pending 'not implemented'

    3.times do
      result = ReservationService.new(item_id: item.id, worker_id: worker1.id, quantity: 3).call
      break unless result
    end

    item.reload
    expect(item.stock_quantity).to be >= 0
    expect(item.stock_quantity).to be < 10
  end

  it 'prevents ghost reservations if one crashes before committing' do
    pending 'not implemented'

    # Stub the call method for a specific worker to simulate a crash
    allow_any_instance_of(ReservationService).to receive(:call).and_wrap_original do |method, *args|
      service = method.receiver
      if service.send(:worker_id) == worker1.id
        raise "Simulated crash"
      else
        true
      end
    end

    # Swallow the simulated crash
    begin
      ReservationService.new(item_id: item.id, worker_id: worker1.id, quantity: 5).call
    rescue
      # ignored
    end

    success = ReservationService.new(item_id: item.id, worker_id: worker2.id, quantity: 5).call
    expect(success).to be true

    item.reload
    expect(item.stock_quantity).to eq(5)
  end

  # TODO: it prevents deadlocks when reserving multiple items in different orders
end

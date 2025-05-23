require 'rails_helper'

RSpec.describe ReservationService do
  let(:item) { Item.create!(name: 'Test item', stock_quantity: 1) }
  let(:worker) { Worker.create!(name: 'Test worker') }
  let(:quantity) { 1 }

  subject(:service) { described_class.new(item_id: item.id, worker_id: worker.id, quantity: quantity) }

  describe '#call' do
    it 'reserves an item' do
      expect { service.call }
        .to change(Reservation, :count)
        .from(0).to(1)
        .and change { item.reload.stock_quantity }.from(1).to(0)

      expect(Reservation.first).to have_attributes(
        item_id: item.id,
        worker_id: worker.id,
        quantity: 1,
      )
    end

    context 'when quantity exceeds available stock' do
      let(:quantity) { item.stock_quantity + 1 }

      it 'does not oversell stock' do
        expect { service.call }
          .to change(Reservation, :count)
          .from(0).to(1)
          .and change { item.reload.stock_quantity }.from(1).to(0)

        expect(Reservation.first).to have_attributes(
          item_id: item.id,
          worker_id: worker.id,
          quantity: 1,
        )
      end
    end

    context 'when updating stock quantity fails' do
      before do
        allow_any_instance_of(Item)
          .to receive(:update!)
          .and_raise(StandardError, 'test error')
      end

      it 'doesnt save reservation' do
        expect { service.call }
          .to raise_error(StandardError, 'test error')
          .and change(Reservation, :count).by(0)
      end
    end
  end
end

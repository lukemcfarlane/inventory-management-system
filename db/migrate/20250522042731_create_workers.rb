class CreateWorkers < ActiveRecord::Migration[8.0]
  def change
    create_table :workers do |t|
      t.string :name

      t.timestamps
    end
  end
end

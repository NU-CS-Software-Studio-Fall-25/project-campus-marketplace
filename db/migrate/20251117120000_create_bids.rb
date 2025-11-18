class CreateBids < ActiveRecord::Migration[8.0]
  def change
    create_table :bids do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.decimal :response_amount, precision: 10, scale: 2
      t.text :message
      t.text :response_message
      t.datetime :responded_at

      t.timestamps
    end

    add_index :bids, [ :listing_id, :buyer_id ]
  end
end

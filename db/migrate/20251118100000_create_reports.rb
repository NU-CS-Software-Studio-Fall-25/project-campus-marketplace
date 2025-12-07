class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reason, null: false
      t.text :details
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :reports, [ :listing_id, :reporter_id ], unique: true
  end
end

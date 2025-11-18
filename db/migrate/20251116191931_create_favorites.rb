class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true

      t.timestamps
    end

  add_index :favorites, [ :user_id, :listing_id ], unique: true
    add_column :listings, :favorites_count, :integer, null: false, default: 0
  end
end

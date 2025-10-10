class CreateListings < ActiveRecord::Migration[7.2]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.integer :user_id

      t.timestamps
    end
  end
end

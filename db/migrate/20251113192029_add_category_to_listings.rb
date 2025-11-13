class AddCategoryToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :category, :string, null: false, default: "other"
  end
end

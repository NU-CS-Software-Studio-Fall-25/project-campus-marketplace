class AddEmailConfirmationToUsers < ActiveRecord::Migration[8.0]
  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def up
    add_column :users, :confirmation_token_digest, :string
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :confirmed_at, :datetime
    add_index :users, :confirmation_token_digest

    MigrationUser.reset_column_information
    MigrationUser.where(confirmed_at: nil).update_all(confirmed_at: Time.current)
  end

  def down
    remove_index :users, :confirmation_token_digest if index_exists?(:users, :confirmation_token_digest)
    remove_column :users, :confirmed_at if column_exists?(:users, :confirmed_at)
    remove_column :users, :confirmation_sent_at if column_exists?(:users, :confirmation_sent_at)
    remove_column :users, :confirmation_token_digest if column_exists?(:users, :confirmation_token_digest)
  end
end

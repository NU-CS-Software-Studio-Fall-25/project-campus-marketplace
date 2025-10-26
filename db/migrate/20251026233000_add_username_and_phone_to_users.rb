class AddUsernameAndPhoneToUsers < ActiveRecord::Migration[8.0]
  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def up
    add_column :users, :username, :string
    add_column :users, :phone_number, :string
    add_index :users, :username, unique: true

    MigrationUser.reset_column_information
    MigrationUser.find_each do |user|
      base_username = user.email_address.to_s.split("@").first.presence || "user#{user.id}"
      parameterized_base = base_username.parameterize(separator: "_").presence || "user#{user.id}"
      candidate = parameterized_base
      suffix = 1

      while MigrationUser.exists?(username: candidate)
        candidate = "#{parameterized_base}_#{suffix}"
        suffix += 1
      end

      email_candidate = user.email_address

      unless email_candidate&.downcase&.end_with?("@u.northwestern.edu")
        email_base = candidate
        email_candidate = "#{email_base}@u.northwestern.edu"
        email_suffix = 1

        while MigrationUser.exists?(email_address: email_candidate)
          email_candidate = "#{email_base}_#{email_suffix}@u.northwestern.edu"
          email_suffix += 1
        end
      end

      user.update_columns(username: candidate, email_address: email_candidate.downcase)
    end

    change_column_null :users, :username, false
  end

  def down
    remove_index :users, :username
    remove_column :users, :phone_number
    remove_column :users, :username
  end
end

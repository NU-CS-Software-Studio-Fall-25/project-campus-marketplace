class AddNamesToUsers < ActiveRecord::Migration[8.0]
  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      first_name = build_first_name_for(user)
      last_name = build_last_name_for(user, first_name)

      user.update_columns(first_name: first_name, last_name: last_name)
    end

    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end

  private
    def build_first_name_for(user)
      source = user.email_address.to_s.split("@").first
      formatted = source.to_s.tr("._-", " ").squeeze(" ").strip.titleize

      formatted.presence || user.username.to_s.tr("._-", " ").squeeze(" ").strip.titleize.presence || "Student"
    end

    def build_last_name_for(user, first_name)
      remainder = user.username.to_s.tr("._-", " ").squeeze(" ").strip.titleize
      tokens = remainder.split

      candidate = tokens.reject { |token| token.casecmp?(first_name) }.first
      candidate.presence || "Wildcat"
    end
end

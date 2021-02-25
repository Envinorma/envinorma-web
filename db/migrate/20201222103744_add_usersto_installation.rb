# frozen_string_literal: true

class AddUserstoInstallation < ActiveRecord::Migration[6.0]
  def change
    add_reference :installations, :user, index: true, foreign_key: true
  end
end

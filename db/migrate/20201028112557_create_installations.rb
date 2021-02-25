# frozen_string_literal: true

class CreateInstallations < ActiveRecord::Migration[6.0]
  def change
    create_table :installations do |t|
      t.string :name
      t.datetime :date

      t.timestamps
    end
  end
end

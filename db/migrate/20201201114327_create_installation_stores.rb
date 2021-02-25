# frozen_string_literal: true

class CreateInstallationStores < ActiveRecord::Migration[6.0]
  def change
    create_table :installation_stores do |t|
      t.string :name
      t.jsonb :data

      t.timestamps
    end
  end
end

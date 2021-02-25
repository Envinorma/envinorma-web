# frozen_string_literal: true

class CreateAP < ActiveRecord::Migration[6.0]
  def change
    create_table :aps do |t|
      t.string :installation_s3ic_id
      t.string :description
      t.date :date
      t.string :url
      t.references :installation, null: false, foreign_key: true
    end
  end
end

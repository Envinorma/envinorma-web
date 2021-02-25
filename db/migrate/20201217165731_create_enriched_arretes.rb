# frozen_string_literal: true

class CreateEnrichedArretes < ActiveRecord::Migration[6.0]
  def change
    create_table :enriched_arretes do |t|
      t.jsonb :data
      t.string :short_title
      t.string :title
      t.boolean :unique_version
      t.string :installation_date_criterion_left
      t.string :installation_date_criterion_right
      t.string :aida_url
      t.string :legifrance_url
      t.jsonb :summary
      t.references :arrete, null: false, foreign_key: true
    end
  end
end

class CreateAlinea < ActiveRecord::Migration[6.0]
  def change
    create_table :alineas do |t|
      t.integer :rank
      t.boolean :active
      t.string :text
      t.jsonb :table
      t.references :section, null: false, foreign_key: true
    end
  end
end

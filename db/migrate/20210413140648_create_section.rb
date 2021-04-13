class CreateSection < ActiveRecord::Migration[6.0]
  def change
    create_table :sections do |t|
      t.integer :rank
      t.string :title
      t.integer :level
      t.boolean :active
      t.boolean :modified
      t.string :warnings
      t.string :reference_str
      t.string :previous_version
      t.references :arrete, null: false, foreign_key: true
    end
  end
end

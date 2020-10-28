class CreateClassements < ActiveRecord::Migration[6.0]
  def change
    create_table :classements do |t|
      t.integer :rubrique
      t.string :regime
      t.string :alinea
      t.references :installation, null: false, foreign_key: true

      t.timestamps
    end
  end
end

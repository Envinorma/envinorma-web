class CreateUniqueClassement < ActiveRecord::Migration[6.0]
  def change
    create_table :unique_classements do |t|
      t.string :rubrique
      t.string :regime
      t.string :alinea
    end
  end
end

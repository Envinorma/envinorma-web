class CreateClassementStores < ActiveRecord::Migration[6.0]
  def change
    create_table :classement_stores do |t|
      t.string :rubrique
      t.string :regime
      t.string :alinea
      t.string :activite
      t.string :seuil

      t.timestamps
    end
  end
end

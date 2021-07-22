class AddClassementReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :classement_references do |t|
      t.string :rubrique
      t.string :regime
      t.string :alinea
      t.string :description
    end
  end
end

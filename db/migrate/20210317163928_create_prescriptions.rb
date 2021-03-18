class CreatePrescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :prescriptions do |t|
      t.string :reference
      t.string :content
      t.references :ap, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end

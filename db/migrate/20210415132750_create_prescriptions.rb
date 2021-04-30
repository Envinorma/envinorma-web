class CreatePrescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :prescriptions do |t|
      t.string :reference
      t.string :content
      t.string :alinea_id
      t.bigint :from_am_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

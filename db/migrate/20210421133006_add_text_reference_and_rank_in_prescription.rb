class AddTextReferenceAndRankInPrescription < ActiveRecord::Migration[6.0]
  def change
    add_column :prescriptions, :text_reference, :string
    add_column :prescriptions, :rank, :string
  end
end

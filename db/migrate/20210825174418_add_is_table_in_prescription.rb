class AddIsTableInPrescription < ActiveRecord::Migration[6.0]
  def change
    add_column :prescriptions, :is_table, :boolean, default: false, null: false
  end
end

class AddNameInPrescription < ActiveRecord::Migration[6.0]
  def change
    add_column :prescriptions, :name, :string
  end
end

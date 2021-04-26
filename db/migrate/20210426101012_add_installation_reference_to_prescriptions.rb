class AddInstallationReferenceToPrescriptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :prescriptions, :installation, index: true, foreign_key: true
  end
end

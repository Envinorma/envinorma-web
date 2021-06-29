class AddTopicInPrescription < ActiveRecord::Migration[6.0]
  def change
    add_column :prescriptions, :topic, :string
  end
end

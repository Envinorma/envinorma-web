class GroupPrescriptionsByTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :group_prescriptions_by_topic, :boolean
  end
end

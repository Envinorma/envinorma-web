class RenameGroupByTopicsAttribute < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :group_prescriptions_by_topic
    add_column :users, :consults_precriptions_by_topics, :boolean, null: false, default: false
  end
end

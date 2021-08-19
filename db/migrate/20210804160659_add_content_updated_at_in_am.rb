class AddContentUpdatedAtInAM < ActiveRecord::Migration[6.0]
  def change
    add_column :ams, :content_updated_at, :datetime, null: false, :default => '2021-01-01 00:00:00'.to_datetime
  end
end

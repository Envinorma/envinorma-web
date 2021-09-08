class ChangeDefaultOfModifiedAtInAM < ActiveRecord::Migration[6.0]
  def change
    change_column_default :ams, :content_updated_at, '2021-01-01 00:00:00'.to_datetime
  end
end

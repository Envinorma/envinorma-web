class ChangeUrlToIdForAPs < ActiveRecord::Migration[6.0]
  def change
    rename_column :aps, :url, :georisques_id
  end
end

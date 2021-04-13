class ChangeAPUrls < ActiveRecord::Migration[6.0]
  def change
    remove_column :aps, :svg_url
    rename_column :aps, :url, :georisques_id
  end
end

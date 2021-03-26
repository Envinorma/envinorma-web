class AddSvgUrlToAPs < ActiveRecord::Migration[6.0]
  def change
    add_column :aps, :svg_url, :string
  end
end

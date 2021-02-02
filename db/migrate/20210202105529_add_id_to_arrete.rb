class AddIdToArrete < ActiveRecord::Migration[6.0]
  def change
    add_column :arretes, :cid, :string
  end
end

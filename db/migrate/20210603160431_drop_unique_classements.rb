class DropUniqueClassements < ActiveRecord::Migration[6.0]
  def change
    drop_table :unique_classements
    drop_table :arretes_unique_classements
  end
end

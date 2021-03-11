class DropArreteclassementsAndInstStore < ActiveRecord::Migration[6.0]
  def change
    drop_table :installation_stores
    drop_table :arretes_classements
  end
end

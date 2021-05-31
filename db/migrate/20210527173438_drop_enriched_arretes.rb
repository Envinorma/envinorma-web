class DropEnrichedArretes < ActiveRecord::Migration[6.0]
  def change
    drop_table :enriched_arretes
  end
end

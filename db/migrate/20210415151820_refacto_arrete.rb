class RefactoArrete < ActiveRecord::Migration[6.0]
  def change
    remove_column :arretes, :name
    add_column :arretes, :classements_with_alineas, :jsonb
    add_column :arretes, :enriched_from_id, :bigint
  end
end

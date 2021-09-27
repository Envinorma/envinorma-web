class CreateAlineaStore < ActiveRecord::Migration[6.0]
  def change
    create_table(:alinea_store, primary_key: [:section_id, :index_in_section]) do |t|
      t.string :section_id
      t.bigint :index_in_section
      t.bigint :am_id
      t.string :section_name
      t.string :section_reference
      t.string :section_rank
      t.string :topic
      t.string :content
      t.boolean :is_table
    end
  end
end

class CreateArretes < ActiveRecord::Migration[6.0]
  def change
    create_table :arretes do |t|
      t.string :name
      t.jsonb :data
      t.references :installation, null: false, foreign_key: true

      t.timestamps
    end
  end
end

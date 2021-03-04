class MoveReferenceFromClassementToUniqueClassement < ActiveRecord::Migration[6.0]
  def change
    create_join_table :arretes, :unique_classements
  end
end

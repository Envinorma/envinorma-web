class RemoveArretesFromClassements < ActiveRecord::Migration[6.0]
  def change
    remove_reference :classements, :arrete
  end
end

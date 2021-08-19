class AddIsTransverseInAM < ActiveRecord::Migration[6.0]
  def change
    add_column :ams, :is_transverse, :boolean, null: false, default: false
  end
end

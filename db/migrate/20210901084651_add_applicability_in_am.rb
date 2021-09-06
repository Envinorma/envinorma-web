class AddApplicabilityInAM < ActiveRecord::Migration[6.0]
  def change
    add_column :ams, :applicability, :jsonb
  end
end

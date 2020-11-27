class AddSummaryToArretes < ActiveRecord::Migration[6.0]

  def change
    add_column :arretes, :summary, :jsonb
  end
end

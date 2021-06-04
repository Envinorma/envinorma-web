class ImproveClassementDates < ActiveRecord::Migration[6.0]
  def change
    rename_column :classements, :date_autorisation, :date_mise_en_service
    add_column :classements, :date_autorisation, :date
  end
end

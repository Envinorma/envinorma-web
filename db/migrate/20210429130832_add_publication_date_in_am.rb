class AddPublicationDateInAM < ActiveRecord::Migration[6.0]
  def change
    add_column :arretes, :publication_date, :date
    remove_column :arretes, :short_title
  end
end

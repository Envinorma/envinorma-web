class RenamePublicationDate < ActiveRecord::Migration[6.0]
  def change
    rename_column :arretes, :publication_date, :date_of_signature
  end
end


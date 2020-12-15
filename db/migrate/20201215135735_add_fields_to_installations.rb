class AddFieldsToInstallations < ActiveRecord::Migration[6.0]
  def change
    remove_column :installations, :date
    add_column :installations, :s3ic_id, :string
    add_column :installations, :region, :string
    add_column :installations, :department, :string
    add_column :installations, :zipcode, :string
    add_column :installations, :city, :string
    add_column :installations, :last_inspection, :date
    add_column :installations, :regime, :string
    add_column :installations, :seveso, :string
    add_column :installations, :state, :string
  end
end

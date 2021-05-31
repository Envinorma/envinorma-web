class ImproveAmParametrization < ActiveRecord::Migration[6.0]
  def change
    remove_column :arretes, :unique_version
    remove_column :arretes, :installation_date_criterion_left
    remove_column :arretes, :installation_date_criterion_right
    remove_column :arretes, :summary
    remove_column :arretes, :enriched_from_id
    add_column :arretes, :version_descriptor, :jsonb
    add_column :arretes, :default_version, :boolean
  end
end

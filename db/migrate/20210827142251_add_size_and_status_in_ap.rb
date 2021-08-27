class AddSizeAndStatusInAP < ActiveRecord::Migration[6.0]
  def change
    add_column :aps, :size, :integer, nullable: true
    add_column :aps, :status, :string, nullable: true
  end
end

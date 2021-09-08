class ChangeArretesToAMs < ActiveRecord::Migration[6.0]
  def change
    rename_table :arretes, :ams
  end
end

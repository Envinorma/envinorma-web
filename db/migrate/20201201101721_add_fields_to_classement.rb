# frozen_string_literal: true

class AddFieldsToClassement < ActiveRecord::Migration[6.0]
  def change
    add_column :classements, :date_autorisation, :date
    add_column :classements, :volume, :string
    add_column :classements, :seuil, :string
  end
end

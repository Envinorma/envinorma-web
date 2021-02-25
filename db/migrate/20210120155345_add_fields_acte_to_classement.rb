# frozen_string_literal: true

class AddFieldsActeToClassement < ActiveRecord::Migration[6.0]
  def change
    add_column :classements, :rubrique_acte, :string
    add_column :classements, :regime_acte, :string
    add_column :classements, :alinea_acte, :string
  end
end

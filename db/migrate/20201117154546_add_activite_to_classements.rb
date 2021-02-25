# frozen_string_literal: true

class AddActiviteToClassements < ActiveRecord::Migration[6.0]
  def change
    add_column :classements, :activite, :string
  end
end

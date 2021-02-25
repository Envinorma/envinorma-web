# frozen_string_literal: true

class ChangeRubriqueFromIntegerToString < ActiveRecord::Migration[6.0]
  def change
    change_column :classements, :rubrique, :string
  end
end

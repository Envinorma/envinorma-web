# frozen_string_literal: true

class CreateArretesClassementsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :arretes, :classements
  end
end

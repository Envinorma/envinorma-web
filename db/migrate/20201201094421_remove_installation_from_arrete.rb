# frozen_string_literal: true

class RemoveInstallationFromArrete < ActiveRecord::Migration[6.0]
  def change
    remove_reference :arretes, :installation
    add_reference :classements, :arrete, index: true, foreign_key: true
  end
end

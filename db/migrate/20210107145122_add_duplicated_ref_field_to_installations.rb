# frozen_string_literal: true

class AddDuplicatedRefFieldToInstallations < ActiveRecord::Migration[6.0]
  def change
    add_column :installations, :duplicated_from_id, :bigint
  end
end

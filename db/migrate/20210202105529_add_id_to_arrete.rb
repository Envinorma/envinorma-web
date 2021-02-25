# frozen_string_literal: true

class AddIdToArrete < ActiveRecord::Migration[6.0]
  def change
    add_column :arretes, :cid, :string
  end
end

# frozen_string_literal: true

class AddMultipleFieldsToArrete < ActiveRecord::Migration[6.0]
  def change
    add_column :arretes, :short_title, :string
    add_column :arretes, :title, :string
    add_column :arretes, :unique_version, :boolean
    add_column :arretes, :installation_date_criterion_left, :string
    add_column :arretes, :installation_date_criterion_right, :string
    add_column :arretes, :aida_url, :string
    add_column :arretes, :legifrance_url, :string
  end
end

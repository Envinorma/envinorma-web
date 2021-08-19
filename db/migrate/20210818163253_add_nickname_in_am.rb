class AddNicknameInAM < ActiveRecord::Migration[6.0]
  def change
    add_column :ams, :nickname, :string
  end
end

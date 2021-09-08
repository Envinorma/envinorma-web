class RenameAPStatusAttributeAsOcrStatus < ActiveRecord::Migration[6.0]
  def change
    rename_column :aps, :status, :ocr_status
  end
end

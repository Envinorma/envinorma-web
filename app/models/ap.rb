# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :georisques_id, :installation_id, :installation_s3ic_id, presence: true
  validates :georisques_id, length: { is: 36 }
  validates :georisques_id, format: { with: %r{\A([A-Z]{1}/[a-f0-9]{1}/[a-f0-9]{32})\z},
                                      message: 'check georisques_id format' }

  validates :installation_s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                             message: 'check s3ic_id format' }

  def title
    "#{description} - #{date.strftime('%d/%m/%y')}"
  end

  def short_title
    "AP - #{date.strftime('%d/%m/%y')}"
  end

  class << self
    def create_hash_from_csv_row(ap_raw)
      {
        'installation_s3ic_id' => ap_raw['installation_s3ic_id'],
        'description' => ap_raw['description'],
        'date' => ap_raw['date'],
        'georisques_id' => ap_raw['georisques_id']
      }
    end

    def delete_from_georisques_ids(georisques_ids_to_delete)
      Rails.logger.info "Deleting #{georisques_ids_to_delete.count} APs..."
      nb_aps = AP.where(georisques_id: georisques_ids_to_delete).delete_all
      Rails.logger.info("...deleted #{nb_aps} APs.")
    end
  end
end

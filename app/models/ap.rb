# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :georisques_id, :installation_s3ic_id, presence: true
  validates :georisques_id, length: { is: 36 }
  validates :georisques_id, format: { with: %r{\A([A-Z]{1}/[a-f0-9]{1}/[a-f0-9]{32})\z},
                                      message: 'check georisques_id format' }

  validates :installation_s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                             message: 'check s3ic_id format' }

  validates :ocr_status, inclusion: { in: %w[null ERROR SUCCESS NOT_ATTEMPTED],
                                      message: 'check ocr_status format' }

  def title
    "#{description} - #{date.strftime('%d/%m/%y')}"
  end

  def short_title
    "AP - #{date.strftime('%d/%m/%y')}"
  end

  def ocr_version_exists?
    ocr_status == 'SUCCESS'
  end

  def small_enough?
    size.present? && size < 13.megabytes
  end

  def url
    "https://storage.sbg.cloud.ovh.net/v1/AUTH_3287ea227a904f04ad4e8bceb0776108/ap/#{georisques_id}.pdf"
  end

  def georisques_url
    "http://documents.installationsclassees.developpement-durable.gouv.fr/commun/#{georisques_id}.pdf"
  end

  class << self
    def create_hash_from_csv_row(ap_raw)
      {
        'installation_s3ic_id' => ap_raw['installation_s3ic_id'],
        'description' => ap_raw['description'],
        'date' => ap_raw['date'],
        'georisques_id' => ap_raw['georisques_id'],
        'ocr_status' => ap_raw['ocr_status'],
        'size' => ap_raw['size']
      }
    end

    def delete_from_georisques_ids(georisques_ids_to_delete)
      Rails.logger.info "Deleting #{georisques_ids_to_delete.count} APs..."
      nb_aps = AP.where(georisques_id: georisques_ids_to_delete).delete_all
      Rails.logger.info("...deleted #{nb_aps} APs.")
    end
  end
end

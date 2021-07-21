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
    def create_hash_from_csv_row(ap_raw, s3ic_id_to_envinorma_id)
      s3ic_id = ap_raw['installation_s3ic_id']
      if s3ic_id_to_envinorma_id.nil?
        installation_id = 1
      else
        raise "s3ic_id #{s3ic_id} not found" unless s3ic_id_to_envinorma_id.key?(s3ic_id)

        installation_id = s3ic_id_to_envinorma_id[s3ic_id]
      end
      {
        'installation_s3ic_id' => s3ic_id,
        'description' => ap_raw['description'],
        'date' => ap_raw['date'],
        'georisques_id' => ap_raw['georisques_id'],
        'installation_id' => installation_id
      }
    end
  end
end

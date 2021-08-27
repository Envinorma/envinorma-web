# frozen_string_literal: true

FactoryBot.define do
  factory :ap do
    description { 'APC' }
    date { '27/04/2021'.to_date }
    installation_s3ic_id { '0065.06351' }
    georisques_id { 'D/b/888cd0e0031343ebae4c0e28ef5d8bab' }
    ocr_status { 'SUCCESS' }
    size { 4.megabytes }
    installation
  end
end

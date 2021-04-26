# frozen_string_literal: true

FactoryBot.define do
  factory :ap do
    description { 'APC' }
    date { Date.today }
    installation_s3ic_id { '0065.06351' }
    georisques_id { 'D/b/888cd0e0031343ebae4c0e28ef5d8bab' }
    installation
  end
end

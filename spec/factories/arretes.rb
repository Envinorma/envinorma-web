# frozen_string_literal: true

FactoryBot.define do
  factory :arrete do
    trait :classement_2521_E do
      path = File.join(Rails.root, 'spec', 'fixtures', 'arretes', 'JORFTEXT000038358856.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      publication_date { am['publication_date'].to_date }
      title { am.dig('title', 'text') }
      unique_version { am['unique_version'] }
      installation_date_criterion_left { am.dig('installation_date_criterion', 'left_date') }
      installation_date_criterion_right { am.dig('installation_date_criterion', 'right_date') }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
    end
  end
end

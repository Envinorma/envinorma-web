# frozen_string_literal: true

FactoryBot.define do
  factory :arrete do
    trait :classement_2521_E do
      path = File.join(Rails.root, 'spec', 'fixtures', 'arretes', 'JORFTEXT000038358856.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { true }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end
  end
end

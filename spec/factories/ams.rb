# frozen_string_literal: true

FactoryBot.define do
  factory :am do
    trait :classement_2521_E do
      path = Rails.root.join('spec/fixtures/ams/JORFTEXT000038358856.json')
      am = JSON.parse(File.read(path))
      data { { 'sections' => am['sections'] } }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      nickname { '' }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
      applicability { am['applicability'] }
    end

    trait :fake_am1 do
      path = Rails.root.join('spec/fixtures/ams/fake_am_1.json')
      am = JSON.parse(File.read(path))
      data { { 'sections' => am['sections'] } }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      nickname { '' }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
      applicability { am['applicability'] }
    end

    trait :fake_am2 do
      path = Rails.root.join('spec/fixtures/ams/am_with_modified_section.json')
      am = JSON.parse(File.read(path))
      data { { 'sections' => am['sections'] } }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      nickname { '' }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
      applicability { am['applicability'] }
    end
  end
end

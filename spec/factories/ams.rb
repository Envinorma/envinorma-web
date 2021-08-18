# frozen_string_literal: true

FactoryBot.define do
  factory :am do
    trait :classement_2521_E do
      path = Rails.root.join('spec/fixtures/ams/JORFTEXT000038358856.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { true }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end

    trait :fake_am_1_default do
      path = Rails.root.join('spec/fixtures/ams/fake_am_1/default_version.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { true }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end

    trait :fake_am_1_after2010 do
      path = Rails.root.join('spec/fixtures/ams/fake_am_1/after_2010.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { false }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end

    trait :fake_am_1_before2010 do
      path = Rails.root.join('spec/fixtures/ams/fake_am_1/before_2010.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { false }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end

    trait :fake_am2 do
      path = Rails.root.join('spec/fixtures/ams/am_with_modified_section.json')
      am = JSON.parse(File.read(path))
      data { am }
      cid { am['id'] }
      is_transverse { am['is_transverse'] }
      date_of_signature { am['date_of_signature'].to_date }
      title { am.dig('title', 'text') }
      version_descriptor { am['version_descriptor'] }
      default_version { false }
      aida_url { am['aida_url'] }
      legifrance_url { am['legifrance_url'] }
      classements_with_alineas { am['classements_with_alineas'] }
    end
  end
end

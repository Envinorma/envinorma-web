# frozen_string_literal: true

FactoryBot.define do
  factory :prescription do
    reference { 'ref' }
    content { 'content' }
    alinea_id { '0' }
    from_am_id { 'am-id' }
    text_reference { 'am-id' }
    rank { '1' }
    user_id { 1 }
    installation_id { 1 }
    is_table { false }

    trait :from_ap do
      from_am_id { nil }
      text_reference { 'AP 2020' }
    end

    trait :table do
      is_table { true }
      content { Rails.root.join('spec/fixtures/fiche_inspection/table.json').read }
    end

    trait :other_am do
      from_am_id { 'other-am' }
      text_reference { 'other-am' }
    end
  end
end

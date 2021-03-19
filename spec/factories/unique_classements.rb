# frozen_string_literal: true

FactoryBot.define do
  factory :unique_classement do
    trait :classement_2521_E do
      rubrique { '2521' }
      regime { 'E' }
    end
  end
end

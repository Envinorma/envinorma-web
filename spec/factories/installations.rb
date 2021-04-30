# frozen_string_literal: true

FactoryBot.define do
  factory :installation do
    trait :eva_industries do
      name { 'EVA INDUSTRIES' }
      s3ic_id { '0065.06351' }
      region { 'ILE-DE-FRANCE' }
      department { 'SEINE-SAINT-DENIS' }
      zipcode { '93600' }
      city { 'AULNAY SOUS BOIS' }
      regime { 'E' }
      seveso { 'NS' }
      state { 'En fonctionnement' }
    end

    trait :sepanor do
      name { 'SEPANOR' }
      s3ic_id { '0065.06067' }
      region { 'ILE-DE-FRANCE' }
      department { "VAL D'OISE" }
      zipcode { '95066' }
      city { "ST OUEN L'AUMONE" }
      regime { 'E' }
      seveso { 'NS' }
      state { 'En fonctionnement' }
    end
  end
end

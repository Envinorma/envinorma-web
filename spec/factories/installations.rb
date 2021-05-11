# frozen_string_literal: true

FactoryBot.define do
  factory :installation do
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
end

# frozen_string_literal: true

module FeatureHelper
  def visit_eva_industries_prescriptions_page
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    click_link('Voir les prescriptions')
  end
end

RSpec.configure do |config|
  config.include FeatureHelper, type: :feature
end

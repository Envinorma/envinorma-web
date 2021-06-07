# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'test AM list computation', js: true do
  before(:each) do
    FactoryBot.create(:arrete, :classement_2521_E)
    FactoryBot.create(:arrete, :fake_arrete_1_default)
    FactoryBot.create(:arrete, :fake_arrete_1_after2010)
    FactoryBot.create(:arrete, :fake_arrete_1_before2010)
  end

  it 'displays no AM when installation has no classement' do
    FactoryBot.create(:installation)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 0
  end

  it 'displays no AM when installation has classement with no AM' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2345_D, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 0
  end

  it 'displays default version when several classements match the same AM' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 1
    expect(first('.js_arrete_checkbox')['data-arrete-id']).to eq '2'
  end

  it 'displays the applicable version when the is only one classement' do
    installation_eva_industries = FactoryBot.create(:installation)

    # It returns version before 2010 when date is before 2010
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 1
    expect(first('.js_arrete_checkbox')['data-arrete-id']).to eq '4'

    # It returns default version when only classement has no date
    classement = Classement.find(1)
    classement.date_mise_en_service = nil
    classement.save
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 1
    expect(first('.js_arrete_checkbox')['data-arrete-id']).to eq '2'

    # It returns version after 2010 when date is after 2010
    classement = Classement.find(1)
    classement.date_mise_en_service = 'Fri, 30 Jul 2020'
    classement.save
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_arrete_checkbox').count).to eq 1
    expect(first('.js_arrete_checkbox')['data-arrete-id']).to eq '3'
  end

  it 'displays correctly sorted AM when two AM are applicable' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    # First classement with regime E, then classement with regime D
    expect(all('.js_arrete_checkbox').count).to eq 2
    expect(first('.js_arrete_checkbox')['data-arrete-id']).to eq '1'
    expect(all('.js_arrete_checkbox')[1]['data-arrete-id']).to eq '4'
  end
end

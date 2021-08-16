# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength
RSpec.describe 'test AM list computation', js: true do
  before do
    FactoryBot.create(:am, :classement_2521_E)
    FactoryBot.create(:am, :fake_am_1_default)
    FactoryBot.create(:am, :fake_am_1_after2010)
    FactoryBot.create(:am, :fake_am_1_before2010)
  end

  it 'displays no AM when installation has no classement' do
    FactoryBot.create(:installation)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 0
  end

  it 'displays no AM when installation has classement with no AM' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2345_D, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 0
  end

  it 'displays default version when several classements match the same AM' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'
  end

  it 'displays the applicable version when there is only one classement' do
    installation_eva_industries = FactoryBot.create(:installation)

    # It returns version before 2010 when date is before 2010
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '4'

    # It returns default version when only classement has no date
    classement = Classement.find(1)
    classement.date_mise_en_service = nil
    classement.save
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'

    # It returns version after 2010 when date is after 2010
    classement = Classement.find(1)
    classement.date_mise_en_service = 'Fri, 30 Jul 2020'
    classement.save
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '3'
  end

  it 'displays correctly sorted AM when two AM are applicable' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    # First classement with regime E, then classement with regime D
    expect(all('.js_am_checkbox').count).to eq 2
    expect(first('.js_am_checkbox')['data-am-id']).to eq '1'
    expect(all('.js_am_checkbox')[1]['data-am-id']).to eq '4'
  end

  it 'displays unchecked AM if there is an alinea mismatch on the classement' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    Classement.first.update!(alinea: '11') # Change with mismatching alinea

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq false
  end

  it 'displays checked AM if classement alinea matches am alinea' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq true
  end

  it 'displays checked AM if any classement alinea matches am alinea' do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    Classement.first.update!(alinea: '11') # Change with mismatching alinea

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq true
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength

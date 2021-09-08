# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test AM list computation', js: true do
  let!(:installation_eva_industries) { create :installation }

  before do
    FactoryBot.create(:am, :classement_2521_E)
    FactoryBot.create(:am, :fake_am1)
  end

  it 'displays no AM when installation has no classement' do
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 0
  end

  it 'displays no AM when installation has classement with no AM' do
    FactoryBot.create(:classement, :classement_2345_D, installation: installation_eva_industries)
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 0
  end

  it 'displays AM as applicable by default if there are several matching classements' do
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'
    expect(first('.js_am_checkbox').checked?).to eq true
  end

  it 'displays the AM with correct checkbox state when there is only one classement' do
    # It displays unchecked AM when date is before 2010
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'
    expect(first('.js_am_checkbox').checked?).to eq false

    # It displays checked AM when only classement has no date
    Classement.find(1).update!(date_mise_en_service: nil)
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'
    expect(first('.js_am_checkbox').checked?).to eq true

    # It displays checked AM when classement is after 2010
    Classement.find(1).update!(date_mise_en_service: 'Fri, 30 Jul 2020')
    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox')['data-am-id']).to eq '2'
    expect(first('.js_am_checkbox').checked?).to eq true
  end

  it 'displays correctly sorted AM when two AM are applicable' do
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

    visit installation_path(installation_eva_industries)

    # First classement with regime E, then classement with regime D
    expect(all('.js_am_checkbox').count).to eq 2
    expect(first('.js_am_checkbox')['data-am-id']).to eq '1'
    expect(all('.js_am_checkbox')[1]['data-am-id']).to eq '2'
  end

  it 'displays unchecked AM if there is an alinea mismatch on the classement' do
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    Classement.first.update!(alinea: '11') # Change with mismatching alinea

    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq false
  end

  it 'displays checked AM if classement alinea matches am alinea' do
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)

    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq true
  end

  it 'displays checked AM if any classement alinea matches am alinea' do
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_after2010, installation: installation_eva_industries)
    Classement.first.update!(alinea: '11') # Change with mismatching alinea

    visit installation_path(installation_eva_industries)

    expect(all('.js_am_checkbox').count).to eq 1
    expect(first('.js_am_checkbox').checked?).to eq true
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

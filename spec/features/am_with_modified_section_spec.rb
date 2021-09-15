# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test prescription selection in modified section', js: true do
  before do
    installation = FactoryBot.create(:installation)
    FactoryBot.create(:am, :fake_am2)
    FactoryBot.create(:classement, :classement_2345_D, installation: installation)
  end

  it 'displays modified version if classement date is before 2020' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section a été modifiée')
    expect(page).to have_content('date de déclaration est antérieure')
  end

  it 'selects only new version alineas when clicking on select all' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Ceci est un alinea modifié')
    find('.select_all', match: :first).click(wait: 4)
    expect(find('input.select_all')).to be_checked
    expect(find('.counter')).to have_content('2')
    expect(Prescription.count).to eq(2)
    expect(Prescription.all.map(&:content)).to include('Ceci est un alinea modifié.')
  end

  it 'displays warning if classement autorisation date is undefined' do
    Classement.first.update!(date_autorisation: nil)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section pourrait être modifiée')
    expect(page).to have_content('date de déclaration est antérieure')
  end

  it 'displays nothing if classement autorisation date is after 2020' do
    Classement.first.update!(date_autorisation: '2021-01-01'.to_date)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).not_to have_content('Cette section')
    expect(page).not_to have_content('date de déclaration est antérieure')
  end

  it 'allows to select prescription in new and old version of section' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))

    # Show previous version
    find('.icon-collapse-mini').click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0_modif')

    # There are 2 alineas : the previous version and the new version
    expect(all('.alineas_checkbox')[0][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0_modif'
    expect(all('.alineas_checkbox')[1][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0'

    # We expect to have both Prescriptions in db after clicking both checkboxes
    execute_script("document.querySelectorAll('.alineas_checkbox')[1].click();")
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '.counter', text: '1'
    expect(Prescription.all.pluck(:alinea_id)).to eq ['941cf0d1bA08_0']
    all('.alineas_checkbox')[0].click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0_modif', checked: true)
    expect(page).to have_selector '.counter', text: '2'
    expect(Prescription.all.pluck(:alinea_id)).to eq %w[941cf0d1bA08_0 941cf0d1bA08_0_modif]
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

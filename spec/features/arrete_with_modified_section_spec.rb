# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test prescription selection in modified section', js: true do
  before do
    FactoryBot.create(:installation)
    FactoryBot.create(:arrete, :fake_arrete2)
  end

  it 'allows to select prescription in new and old version of section' do
    visit arretes_path(Installation.first, arrete_ids: Arrete.all.pluck(:id))

    # Show previous version
    find('.icon-collapse-mini').click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0_modif')

    # There are 2 alineas : the previous version and the new version
    expect(all('.alineas_checkbox')[0][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0_modif'
    expect(all('.alineas_checkbox')[1][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0'

    # We expect to have both Prescriptions in db after clicking both checkboxes
    all('.alineas_checkbox')[1].click
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

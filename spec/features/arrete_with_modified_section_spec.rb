# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'test prescription selection in modified section', js: true do
  before(:all) do
    FactoryBot.create(:installation)
    FactoryBot.create(:arrete, :fake_arrete2)
  end

  it 'allows to select prescription in new and old version of section' do
    visit arretes_path(Installation.first, arrete_ids: Arrete.all.pluck(:id))

    # Show previous version
    find('.icon-collapse-mini').click

    sleep(10)

    # There are 2 alineas : the previous version and the new version
    expect(all('.alineas_checkbox')[0][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0_modif'
    expect(all('.alineas_checkbox')[1][:name]).to eq 'prescription_checkbox_941cf0d1bA08_0'

    # We expect to have both Prescriptions in db after clicking both checkboxes
    all('.alineas_checkbox')[1].click
    sleep(0.3) # ensure prescription persistence was done
    expect(Prescription.all.pluck(:alinea_id)).to eq ['941cf0d1bA08_0']
    all('.alineas_checkbox')[0].click
    sleep(0.3) # ensure prescription persistence was done
    expect(Prescription.all.pluck(:alinea_id)).to eq %w[941cf0d1bA08_0 941cf0d1bA08_0_modif]
  end
end

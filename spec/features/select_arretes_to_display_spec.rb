# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength
RSpec.describe 'select arretes to display feature', js: true do
  before do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_1234_D_before2010, installation: installation_eva_industries)
    FactoryBot.create(:arrete, :classement_2521_E)
    FactoryBot.create(:arrete, :fake_arrete_1_default)
    FactoryBot.create(:arrete, :fake_arrete_1_after2010)
    FactoryBot.create(:arrete, :fake_arrete_1_before2010)
    FactoryBot.create(:ap, installation: installation_eva_industries)
  end

  it 'allows user to select arretes to display' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    # By default, first AM is applicable and second AM is not applicable
    # NB: The matching AM version of fake_arrete_1 is the 3rd version
    # by default AP are checked
    expect(all('.js_checkbox').count).to eq 3
    expect(find('#arrete_1').checked?).to eq true
    expect(find('#arrete_4').checked?).to eq false
    suffix = 'installations/1/arretes?arrete_ids[]=1&ap_ids[]=1'
    expect(find('#arretes_link_button')[:href].end_with?(suffix)).to eq true

    # After clicking on the second AM checkbox, both AM will be displayed
    find('#arrete_4').click
    suffix = 'installations/1/arretes?arrete_ids[]=1&arrete_ids[]=4&ap_ids[]=1'
    expect(find('#arretes_link_button')[:href].end_with?(suffix)).to eq true

    # After clicking on AP checkbox, only AM will be displayed
    execute_script("document.querySelector('#ap_1').click();") # javascript way for `find('#ap_1').click`
    suffix = 'installations/1/arretes?arrete_ids[]=1&arrete_ids[]=4'
    expect(find('#arretes_link_button')[:href].end_with?(suffix)).to eq true

    # After clicking on both checkboxes, no AM or AP will be displayed and button is hidden
    find('#arrete_1').click
    find('#arrete_4').click
    page.find('#arretes_link_button', visible: :hidden)

    # After clicking on AP checkbox, only AP will be displayed and button is visible
    execute_script("document.querySelector('#ap_1').click();") # javascript way for `find('#ap_1').click`
    suffix = 'installations/1/arretes?ap_ids[]=1'
    expect(find('#arretes_link_button')[:href].end_with?(suffix)).to eq true
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength

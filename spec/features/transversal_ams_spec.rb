# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test transversal AM feature', js: true do
  before do
    FactoryBot.create(:installation)
    am = FactoryBot.create(:am, :classement_2521_E)
    am.update!(is_transverse: true)
  end

  it 'allows user to select transveral AMs by using a dropdown.' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(all('.js_am_checkbox').count).to eq 0

    find('.icon-collapse-mini').click

    expect(all('.js_am_checkbox').count).to eq 1
    expect(find('#am_1').checked?).to eq false

    find('#am_1').click
    find('#arretes_link_button').click
    click_link('< Retour à l’installation')

    find('.icon-collapse-mini').click
    expect(all('.js_am_checkbox').count).to eq 1
    expect(find('#am_1').checked?).to eq true
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

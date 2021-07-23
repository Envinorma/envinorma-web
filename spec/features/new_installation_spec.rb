# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'new installations test features', js: true do
  it 'allows user to create a new installation' do
    visit root_path
    expect(page).not_to have_content('Mes installations')
    click_link('Créer une installation fictive')
    fill_in 'Nom de l\'installation', with: 'Eva industries'
    click_button('Créer l\'installation')
    expect(page).to have_content('Eva industries')
    expect(page).to have_content('Mes installations')
    expect(page).not_to have_content('Modifier les classements')
    expect(Installation.count).to eq(1)
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

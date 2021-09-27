# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'new installations test features', js: true do
  before do
    ClassementReference.create(rubrique: 1510, alinea: '2b', regime: 'E', description: 'Entrepôt')
  end

  it 'allows user to create a new installation' do
    visit root_path
    expect(page).not_to have_content('Mes installations')
    click_link('Créer une installation fictive')

    expect(page).to have_button 'Créer l\'installation', disabled: true
    fill_in 'Nom de l\'installation', with: 'Un entrepôt'
    fill_in('autocomplete-classements', with: '1510')
    fill_in('Volume', with: '2000 m3')
    find('li', text: 'E 2b - Entrepôt').click
    click_button('Créer l\'installation')

    expect(page).to have_content('Mes installations')
    expect(page).to have_content('Un entrepôt')
    expect(page).to have_content('1510')
    expect(page).to have_content('2000.0 m3')
    expect(Installation.count).to eq(1)
    expect(Installation.first.s3ic_id).to eq('0000.00000')
    expect(page).not_to have_content('0000.00000')
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

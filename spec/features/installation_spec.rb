# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'installations test features', js: true do
  before(:all) do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation_eva_industries)
  end

  it 'allows user to add and remove classements from a duplicate installation' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).not_to have_content('Mes installations modifiées')

    # Duplicate installation to add new classement
    click_link('Modifier cette installation')
    click_link('Ajouter un nouveau classement')
    fill_in 'Rubrique', with: '1510'
    select 'E', from: 'Régime'
    click_button('Sauvegarder les modifications')

    expect(page).to have_content('Mes installations modifiées')
    expect(page).to have_content('version modifiée')
    expect(page).to have_content('1510')
    expect(Installation.count).to eq 2

    # Duplicated installation does not appear in search
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    expect(page).to have_link '0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS', count: 1
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).not_to have_content('1510')

    # User can retrieve his duplicated installation
    click_link('Consulter votre version modifiée')
    expect(page).to have_content('1510')

    # User can delete classement
    click_link('Modifier cette installation')
    find('#installation_classements_attributes_3__destroy').click
    click_button('Sauvegarder les modifications')
    expect(page).not_to have_content('1510')
  end
end

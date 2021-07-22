# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength
RSpec.describe 'installations test features', js: true do
  before do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation_eva_industries)
  end

  it 'allows user to add, remove, modify classements and modify name from a duplicate installation' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).not_to have_content('Mes installations')

    # Duplicate installation to add new classement
    click_link('Créer une copie de l’installation (accessible par vous seul).')
    expect(page).to have_content('Mes installations')
    expect(page).to have_content('Cette installation a été créée par vos soins')

    # add new classement
    click_link('Ajouter un nouveau classement')
    fill_in 'Rubrique', with: '1510'
    select 'E', from: 'Régime'
    click_button('Sauvegarder les modifications')

    expect(page).to have_content('Cette installation a été créée par vos soins')
    expect(page).to have_content('1510')
    expect(Installation.count).to eq 2

    # Duplicated installation does not appear in search
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    expect(page).to have_link '0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS', count: 1
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).not_to have_content('1510')

    # User can retrieve his duplicated installation
    click_link('Consulter votre version de l’installation.')
    expect(page).to have_content('1510')

    # User can delete classement
    click_link('Modifier les classements')

    4.times.each do |index|
      if find("#installation_classements_attributes_#{index}_rubrique").value.include?('1510')
        find("#installation_classements_attributes_#{index}__destroy").click
      end
    end
    click_button('Sauvegarder les modifications')
    expect(page).not_to have_content('1510')

    # User can modify classement (except 'Rubrique' field)
    click_link('Modifier les classements')
    expect(page).to have_field 'Rubrique', disabled: true
    select 'NC', from: 'Régime', match: :first
    fill_in "Date d'autorisation", match: :first, with: '03/11/2020'
    fill_in 'Date de mise en service', match: :first, with: '03/12/2020'
    click_button('Sauvegarder les modifications')
    expect(page).to have_content('NC')
    expect(page).to have_content('03/11/2020')
    expect(page).to have_content('03/12/2020')

    # User can modify name
    click_link("Modifier le nom de l'installation")
    fill_in "Nom de l'installation", with: 'Nouveau nom'
    click_button('Sauvegarder la modification')
    expect(page).to have_content('Nouveau nom')
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength

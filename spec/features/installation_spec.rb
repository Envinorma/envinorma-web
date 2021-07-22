# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength
RSpec.describe 'installations test features', js: true do
  before do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation_eva_industries)
    ClassementReference.create(rubrique: 1510, alinea: '2b', regime: 'E', description: 'Entrepôt')
  end

  it 'allows user to add and remove classements from a duplicate installation' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).not_to have_content('Mes installations')

    # Duplicate installation to add new classement
    click_link('Créer une copie de l’installation (accessible par vous seul).')
    expect(page).to have_content('Mes installations')
    expect(page).to have_content('Cette installation a été créée par vos soins')

    # add new classement
    click_link('Modifier les classements')
    click_link('Ajouter un nouveau classement')
    fill_in('autocomplete-classements', with: '1510')
    find('li', text: 'E 2b - Entrepôt').click
    click_button('Sauvegarder')

    expect(page).to have_content('Modifier les classements')
    click_link("Retourner sur l'installation")
    expect(page).to have_content('1510')
    expect(Classement.count).to eq 7
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
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass, RSpec/ExampleLength

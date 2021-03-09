# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature tests end to end', js: true do
  it 'allows user to search for an installation and to download odt sheet with prescriptions' do
    installation = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :rubrique2521, installation: installation)
    FactoryBot.create(:classement, :rubrique4801, installation: installation)
    FactoryBot.create(:classement, :rubrique2515, installation: installation)
    arrete = FactoryBot.create(:arrete, :arrete_2521_E)
    unique_classement = FactoryBot.create(:unique_classement)
    ArretesUniqueClassement.create(arrete: arrete, unique_classement: unique_classement)

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    expect(page).to have_content('EVA INDUSTRIES')

    click_link("Voir les prescriptions pour générer une fiche d'inspection")
    expect(page).to have_content('Arrêté du 9 avril 2019')
    find('.select_all', match: :first).click
    click_button("Générer une fiche d'inspection")

    expect(page).to have_content("Arrêté du 9 avril 2019")
    expect(DownloadHelpers.download_content).to have_content "les dispositions du présent arrêté s'appliquent à l'extension"
  end
end

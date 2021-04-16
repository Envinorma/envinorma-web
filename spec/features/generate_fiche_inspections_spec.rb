# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature tests end to end', js: true do
  it 'allows user to search for an installation and to download odt sheet with prescriptions' do
    installation = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation)
    arrete = FactoryBot.create(:arrete, :classement_2521_E)
    unique_classement = FactoryBot.create(:unique_classement, :classement_2521_E)
    ArretesUniqueClassement.create(arrete: arrete, unique_classement: unique_classement)

    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(page).to have_content('EVA INDUSTRIES')
    expect(page).to have_content('Houille, coke, lignite')
    click_link("Voir les prescriptions pour générer une fiche d'inspection")

    expect(page).to have_content('Arrêté du 9 avril 2019')
    find('.select_all', match: :first).click
    find('label', text: '500 mg/m3').click
    click_button("Générer une fiche d'inspection")

    expect(page).to have_content('Arrêté du 9 avril 2019')
    expect(DownloadHelpers.download_content).to have_content "les dispositions du présent arrêté s'appliquent"
    expect(DownloadHelpers.download_content).to have_content '500 mg/m3'
  end
end

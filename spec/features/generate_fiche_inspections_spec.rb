# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
RSpec.describe 'Feature tests end to end', js: true, type: :feature do
  before do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation_eva_industries)
    FactoryBot.create(:arrete, :classement_2521_E)
    FactoryBot.create(:ap, installation: installation_eva_industries)

    installation_sepanor = FactoryBot.create(:installation, name: 'SEPANOR', s3ic_id: '0065.06067', zipcode: '95066',
                                                            city: "ST OUEN L'AUMONE")

    FactoryBot.create(:classement, :classement_2521_E, installation: installation_sepanor)
  end

  it 'allows user to search for an installation and to download odt sheet with prescriptions' do
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')

    expect(page).to have_content('EVA INDUSTRIES')
    expect(page).to have_content('Houille, coke, lignite')
    click_link("Voir les prescriptions pour générer une fiche d'inspection")

    expect(page).to have_content('AM - 09/04/19')
    page.find('#modalPrescriptions', visible: :hidden)

    # Create prescriptions using checkbox select_all
    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)

    expect(page).not_to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E'
    expect(page).to have_selector '.counter', text: '5'
    expect(Prescription.count).to eq 5

    # Delete prescriptions using checkbox select_all
    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: false)
    expect(page).to have_selector '.counter', text: '0'
    expect(Prescription.count).to eq 0

    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '.counter', text: '5'
    expect(Prescription.count).to eq 5

    # Create prescriptions from a row in a table
    find('label', text: '500 mg/m3').click(wait: 4)
    expect(page).to have_selector '.counter', text: '6'
    expect(Prescription.count).to eq 6

    # Create prescriptions from AP
    fill_in 'Référence', with: 'Art. 3'
    fill_in 'Contenu', with: "Prescriptions copier - coller de l'AP"
    click_button('Ajouter une prescription')
    expect(page).to have_selector '.counter', text: '7'
    expect(Prescription.count).to eq 7

    fill_in 'Référence', with: 'Art. 4'
    fill_in 'Contenu', with: "Prescriptions 2 copier - coller de l'AP"
    click_button('Ajouter une prescription')
    expect(page).to have_selector '.counter', text: '8'
    expect(Prescription.count).to eq 8

    # Open modal
    click_on(class: 'circle-fixed-button')

    expect(page).to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E', count: 1
    expect(page).to have_selector '#prescriptions_recap h6', text: 'AP - 27/04/21', count: 1
    expect(page).to have_selector '.prescription', count: '8'

    # Generate Fiche d'inspection
    click_link('Télécharger la fiche')
    expect(DownloadHelpers.download_content).to have_content "les dispositions du présent arrêté s'appliquent"
    expect(DownloadHelpers.download_content).to have_content '500 mg/m3'
    expect(DownloadHelpers.download_content).to have_content "Prescriptions copier - coller de l'AP"

    # After download prescriptions are still present
    page.find('#modalPrescriptions', visible: true)
    expect(page).to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E', count: 1
    expect(page).to have_selector '#prescriptions_recap h6', text: 'AP - 27/04/21', count: 1
    expect(page).to have_selector '.prescription', count: '8'
    expect(Prescription.count).to eq 8

    # Delete one prescription from modal
    click_link('Supprimer', match: :first)
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: false)
    expect(page).to have_selector '.prescription', count: '7'
    expect(Prescription.count).to eq 7

    # Delete all prescriptions from modal
    click_link('Tout supprimer')
    expect(page).to have_selector '.prescription', count: '0'
    expect(Prescription.count).to eq 0

    # Close the modal
    click_button('Fermer')
    page.find('#modalPrescriptions', visible: false)
  end

  it 'saves prescriptions for an installation and a user' do
    visit_eva_industries_prescriptions_page

    # Create prescriptions using checkbox select_all
    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '.counter', text: '5'
    expect(Prescription.count).to eq 5

    # Visit a new installation - Prescriptions are not displayed
    visit root_path
    fill_in('autocomplete', with: 'SEPAN')
    click_link("0065.06067 | SEPANOR - 95066 ST OUEN L'AUMONE")

    expect(page).to have_content('SEPANOR')
    click_link("Voir les prescriptions pour générer une fiche d'inspection")

    expect(page).to have_selector '.counter', text: '0'
    click_on(class: 'circle-fixed-button')
    expect(page).not_to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E', count: 1
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: false)
    expect(page).to have_selector '.prescription', count: '0'

    # Return to installation - prescriptions are still displayed
    visit_eva_industries_prescriptions_page

    click_on(class: 'circle-fixed-button')
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E', count: 1
    expect(page).to have_selector '.prescription', count: '5'
  end

  it 'filter am with topics' do
    visit_eva_industries_prescriptions_page

    expect(page).to have_content('Chapitre Ier : Dispositions générales')
    click_button('Air - odeurs')
    expect(page).to have_selector '.btn-primary', text: 'Air - odeurs'
    expect(page).to have_content("Chapitre VI : Emissions dans l'air")
    expect(page).not_to have_content('Chapitre Ier : Dispositions générales')
    alert_ap = 'Votre sélection "Air - odeurs" a bien été prise en compte mais les arrêtés préfectoraux'
    expect(page).to have_content(alert_ap)

    click_button("Fin d'exploitation")
    expect(page).to have_selector '.btn-primary', text: "Fin d'exploitation"
    expect(page).to have_selector '.btn-light', text: 'Air - odeurs'
    expect(page).to have_content('Cet arrêté ne contient pas de prescriptions correspondant au thème choisi')
    expect(page).not_to have_content('Chapitre Ier : Dispositions générales')
    alert_ap = 'Votre sélection "Fin d\'exploitation" a bien été prise en compte mais les arrêtés préfectoraux'
    expect(page).to have_content(alert_ap)

    click_button("Fin d'exploitation")
    expect(page).to have_selector '.btn-light', text: "Fin d'exploitation"
    expect(page).to have_content('Chapitre Ier : Dispositions générales')
    expect(page).not_to have_content(alert_ap)
  end

  it 'filter selected prescriptions by topics or by arretes' do
    visit_eva_industries_prescriptions_page

    click_button('Air - odeurs')
    expect(page).to have_content("Chapitre VI : Emissions dans l'air")
    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_selector '.counter', text: '4'
    expect(Prescription.count).to eq 4
    expect(Prescription.last.topic).to eq 'AIR_ODEURS'

    click_button('Bruit - vibrations')
    expect(page).to have_content('Chapitre VII : Bruit, vibration et émissions lumineuses')
    find('.select_all', match: :first).click(wait: 4)
    expect(page).to have_selector '.counter', text: '9'
    expect(Prescription.count).to eq 9
    expect(Prescription.last.topic).to eq 'BRUIT_VIBRATIONS'

    # Create prescriptions from AP
    fill_in 'Référence', with: 'Art. 3'
    fill_in 'Contenu', with: "Prescriptions copier - coller de l'AP"
    click_button('Ajouter une prescription')
    expect(page).to have_selector '.counter', text: '10'
    expect(Prescription.count).to eq 10

    find(class: 'circle-fixed-button').click(wait: 4)

    expect(page).to have_content("Fiche d'inspection")
    expect(page).to have_content('Les poussières, gaz polluants ou odeurs sont captés à la source')
    expect(page).not_to have_content('Thème : Air - odeurs')
    expect(page).to have_selector '.btn-secondary', text: 'Grouper par arrêté'
    expect(page).to have_selector '.btn-light', text: 'Grouper par thème'

    click_link('Grouper par thème')
    expect(page).to have_content('Thème : Air - odeurs')
    expect(page).to have_content('Aucun thème')
    expect(page).to have_selector '.btn-light', text: 'Grouper par arrêté'
    expect(page).to have_selector '.btn-secondary', text: 'Grouper par thème'

    click_link('Télécharger la fiche')
    expect(DownloadHelpers.download_content).to have_content 'Air - odeurs'
    expect(DownloadHelpers.download_content).not_to have_content 'Dispositions générales'

    click_link('Grouper par arrêté')
    expect(page).not_to have_content('Thème : Air - odeurs')
  end
end

# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength

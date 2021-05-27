# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature tests end to end', js: true do
  before(:all) do
    installation_eva_industries = FactoryBot.create(:installation)
    FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_4801_D, installation: installation_eva_industries)
    FactoryBot.create(:classement, :classement_2515_D, installation: installation_eva_industries)
    arrete = FactoryBot.create(:arrete, :classement_2521_E)
    unique_classement = FactoryBot.create(:unique_classement, :classement_2521_E)
    ArretesUniqueClassement.create(arrete: arrete, unique_classement: unique_classement)
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
    find('.select_all', match: :first).click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)

    expect(page).not_to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E'
    expect(page).to have_selector '.counter', text: '5'
    expect(Prescription.count).to eq 5

    # Delete prescriptions using checkbox select_all
    find('.select_all', match: :first).click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: false)
    expect(page).to have_selector '.counter', text: '0'
    expect(Prescription.count).to eq 0

    find('.select_all', match: :first).click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '.counter', text: '5'
    expect(Prescription.count).to eq 5

    # Create prescriptions from a row in a table
    find('label', text: '500 mg/m3').click
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

    # Open and close the modal
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
    click_button('Fermer')
    page.find('#modalPrescriptions', visible: false)

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
    visit root_path
    fill_in('autocomplete', with: 'EVA INDUST')
    click_link('0065.06351 | EVA INDUSTRIES - 93600 AULNAY SOUS BOIS')
    click_link("Voir les prescriptions pour générer une fiche d'inspection")

    click_on(class: 'circle-fixed-button')
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: true)
    expect(page).to have_selector '#prescriptions_recap h6', text: 'AM - 09/04/19 - 2521 E', count: 1
    expect(page).to have_selector '.prescription', count: '8'

    find('.delete_prescription', match: :first).click
    expect(page).to have_field('prescription_checkbox_941cf0d1bA08_0', checked: false)
    expect(page).to have_selector '.prescription', count: '7'
    expect(Prescription.count).to eq 7

    click_link('Tout supprimer')
    expect(page).to have_selector '.prescription', count: '0'
    expect(Prescription.count).to eq 0
  end
end

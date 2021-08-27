# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test AP default display', js: true do
  let!(:installation_eva_industries) { create :installation }

  before do
    AP.create!(
      installation_s3ic_id: '0000.00000',
      description: 'test',
      date: '01/01/01'.to_date,
      georisques_id: 'A/1/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      installation_id: installation_eva_industries.id,
      size: 1.megabyte,
      ocr_status: 'SUCCESS'
    )
  end

  it 'displays the AP if small enough' do
    visit arretes_path(installation_eva_industries, ap_ids: [AP.first.id])

    expect(page).to have_css('object')
  end

  it 'does not display the AP if it is too big' do
    AP.first.update(size: 1.gigabyte)

    visit arretes_path(installation_eva_industries, ap_ids: [AP.first.id])

    expect(page).not_to have_css('object')
    expect(page).to have_content('trop volumineux')
  end

  it 'does not display the AP if the OCR was not succesful' do
    AP.first.update(ocr_status: 'ERROR')

    visit arretes_path(installation_eva_industries, ap_ids: [AP.first.id])

    expect(page).not_to have_css('object')
    expect(page).to have_content("L'analyse de caractères de cet arrêté a échoué")
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

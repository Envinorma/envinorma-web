# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test prescription selection in modified section', js: true do
  before do
    installation = FactoryBot.create(:installation)
    FactoryBot.create(:am, :fake_am2)
    FactoryBot.create(:classement, :classement_2345_D, installation: installation)
  end

  it 'displays modified version if classement date is before 2020' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section a été modifiée')
    expect(page).to have_content('date de déclaration est antérieure')
  end

  it 'displays warning if classement autorisation date is undefined' do
    Classement.first.update!(date_autorisation: nil)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section pourrait être modifiée')
    expect(page).to have_content('date de déclaration est antérieure')
  end

  it 'displays nothing if classement autorisation date is after 2020' do
    Classement.first.update!(date_autorisation: '2021-01-01'.to_date)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).not_to have_content('Cette section')
    expect(page).not_to have_content('date de déclaration est antérieure')
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test consult AM with inapplicability', js: true do
  before do
    FactoryBot.create(:installation)
    FactoryBot.create(:am, :classement_2521_E)
  end

  it 'displays potentially inapplicable paragraph if there are no matching classements' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section pourrait être inapplicable')
    expect(page).to have_content('date de mise en service est antérieure')
  end

  it 'displays inapplicable paragraph if classement date is before 2019-04-09' do
    FactoryBot.create(:classement, :classement_2521_E,
                      installation: Installation.first, date_mise_en_service: '2000-01-01'.to_date)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section est inapplicable')
    expect(page).to have_content('date de mise en service est antérieure')
  end

  it 'displays potentially inapplicable paragraph if there are two classements' do
    FactoryBot.create(:classement, :classement_2521_E,
                      installation: Installation.first, date_mise_en_service: '2000-01-01'.to_date)
    FactoryBot.create(:classement, :classement_2521_E,
                      installation: Installation.first, date_mise_en_service: '2000-01-01'.to_date)
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section pourrait être inapplicable')
    expect(page).to have_content('date de mise en service est antérieure')
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

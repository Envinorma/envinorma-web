# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations, RSpec/DescribeClass
RSpec.describe 'test consult AM with volume inapplicability', js: true do
  before do
    FactoryBot.create(:installation)
    FactoryBot.create(:am, :with_volume_inapplicability)
  end

  it 'displays potentially inapplicable paragraph if there are no matching classements' do
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section pourrait être inapplicable')
    expect(page).to have_content('quantité associée à la rubrique est inférieure')
  end

  it 'displays inapplicable paragraph if classement volume is less than 200' do
    FactoryBot.create(:classement, :classement_2345_D,
                      installation: Installation.first, volume: '100.000 u. eq.')
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).to have_content('Cette section est inapplicable')
    expect(page).to have_content('quantité associée à la rubrique est inférieure')
  end

  it 'displays nothing if classement volume is more than 200' do
    FactoryBot.create(:classement, :classement_2345_D,
                      installation: Installation.first, volume: '300.000 u. eq.')
    visit arretes_path(Installation.first, am_ids: AM.all.pluck(:id))
    expect(page).not_to have_content('Cette section est inapplicable')
    expect(page).not_to have_content('quantité associée à la rubrique est inférieure')
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/DescribeClass

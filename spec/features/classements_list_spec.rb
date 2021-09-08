# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'test AM list computation', js: true do
  let!(:installation) { create :installation }

  it 'displays classement by decreasing importance of regime' do
    FactoryBot.create(:classement, :classement_2345_D, installation: installation)
    FactoryBot.create(:classement, :classement_2345_D, installation: installation, regime: 'A')
    FactoryBot.create(:classement, :classement_2345_D, installation: installation, regime: 'E')
    visit installation_path(installation)

    regimes = find('.table').find('tbody').all('tr').map do |tr|
      tr.all('td')[2].text.split("\n")[0]
    end

    expect(regimes).to eq(%w[A E D])
  end
end
# rubocop:enable RSpec/DescribeClass

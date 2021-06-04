# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Installation' do
  let!(:installation) { create :installation }
  let!(:classement) { create :classement, :classement_2521_E, installation: installation }
  let!(:user) { User.create }

  it 'should duplicates installation and its classements for a user' do
    installation_duplicated = installation.duplicate!(user)

    expect(installation_duplicated).to have_attributes(
      name: 'EVA INDUSTRIES',
      s3ic_id: '0065.06351',
      region: 'ILE-DE-FRANCE',
      department: 'SEINE-SAINT-DENIS',
      zipcode: '93600',
      city: 'AULNAY SOUS BOIS',
      regime: 'E',
      seveso: 'NS',
      state: 'En fonctionnement'
    )

    expect(installation_duplicated.classements.count).to eq 1
    expect(installation_duplicated.classements.first).to have_attributes(
      rubrique: '2521',
      regime: 'E',
      alinea: '1',
      installation_id: installation_duplicated.id,
      activite: "Centrale d'enrobage à chaud",
      date_autorisation: 'Tue, 07 May 1974'.to_date,
      date_mise_en_service: 'Tue, 07 May 1974'.to_date,
      rubrique_acte: '2521',
      regime_acte: 'A',
      alinea_acte: '1'
    )
  end

  it 'should not duplicate if user has already a copy' do
    installation.duplicate!(user)
    expect { installation.duplicate!(user) }.to change { Installation.count }.by(0)
  end
end

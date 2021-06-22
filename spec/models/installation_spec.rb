# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Installation' do
  let!(:installation) { create :installation }
  let!(:classement) { create :classement, :classement_2521_E, installation: installation }
  let!(:user) { User.create }

  it 'duplicates installation for a user' do
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
  end

  it 'duplicates installation classements for a user' do
    installation_duplicated = installation.duplicate!(user)
    expect(installation_duplicated.classements.count).to eq 1
  end

  it 'duplicates installation with same classements for a user' do
    installation_duplicated = installation.duplicate!(user)
    expect(installation_duplicated.classements.first).to have_attributes(
      rubrique: classement.rubrique,
      regime: classement.regime,
      alinea: classement.alinea,
      installation_id: installation_duplicated.id,
      activite: classement.activite,
      date_autorisation: classement.date_autorisation,
      date_mise_en_service: classement.date_mise_en_service,
      rubrique_acte: classement.rubrique_acte,
      regime_acte: classement.regime_acte,
      alinea_acte: classement.alinea_acte
    )
  end

  it 'does not duplicate if user has already a copy' do
    installation.duplicate!(user)
    expect { installation.duplicate!(user) }.to change(Installation, :count).by(0)
  end
end

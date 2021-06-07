# frozen_string_literal: true

FactoryBot.define do
  factory :classement do
    trait :classement_2521_E do
      rubrique { '2521' }
      regime { 'E' }
      alinea { '1' }
      installation
      activite { "Centrale d'enrobage à chaud" }
      date_autorisation { 'Tue, 07 May 1974' }
      date_mise_en_service { 'Tue, 07 May 1974' }
      volume { '150000.000 t/an' }
      rubrique_acte { '2521' }
      regime_acte { 'A' }
      alinea_acte { '1' }
    end

    trait :classement_4801_D do
      rubrique { '4801' }
      regime { 'D' }
      alinea { '2' }
      installation
      activite { 'Houille, coke, lignite, charbon de bois, goudron, asphalte, brais et matières bitumineuses' }
      date_autorisation { 'Tue, 07 May 1974' }
      date_mise_en_service { 'Tue, 07 May 1974' }
      volume { ' ' }
      rubrique_acte { '4801' }
      regime_acte { 'D' }
      alinea_acte { '2' }
    end

    trait :classement_2515_D do
      rubrique { '2515' }
      regime { 'D' }
      alinea { 'b' }
      installation
      activite { 'Broyage, concassage,...et autres produits minéraux ou déchets non dangereux inertes' }
      date_autorisation { 'Fri, 30 Jul 2004' }
      date_mise_en_service { 'Fri, 30 Jul 2004' }
      volume { '150.000 kW' }
      rubrique_acte { '2515' }
      regime_acte { 'D' }
      alinea_acte { '1c' }
    end

    trait :classement_1234_D_before2010 do
      rubrique { '1234' }
      regime { 'D' }
      alinea { '1' }
      installation
      activite { 'Fake activité' }
      date_autorisation { 'Fri, 30 Jul 2004' }
      date_mise_en_service { 'Fri, 30 Jul 2004' }
      volume { '15.000 V' }
      rubrique_acte { '1234' }
      regime_acte { 'D' }
      alinea_acte { '1' }
    end

    trait :classement_1234_D_after2010 do
      rubrique { '1234' }
      regime { 'D' }
      alinea { '1' }
      installation
      activite { 'Fake activité' }
      date_autorisation { 'Fri, 30 Jul 2014' }
      date_mise_en_service { 'Fri, 30 Jul 2014' }
      volume { '15.000 V' }
      rubrique_acte { '1234' }
      regime_acte { 'D' }
      alinea_acte { '1' }
    end

    trait :classement_2345_D do
      rubrique { '2345' }
      regime { 'D' }
      alinea { '' }
      installation
      activite { 'Fake activité 2345' }
      date_autorisation { 'Fri, 30 Jul 2014' }
      date_mise_en_service { 'Fri, 30 Jul 2014' }
      volume { '12.000 t' }
      rubrique_acte { '2345' }
      regime_acte { 'D' }
      alinea_acte { '' }
    end
  end
end

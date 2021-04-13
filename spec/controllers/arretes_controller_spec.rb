# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArretesController, type: :controller do
  render_views

  let(:installation) { Installation.create(name: 'Installation test', s3ic_id: '0000.00000') }
  let(:user) { User.create }
  let(:ap) do
    AP.create(installation_s3ic_id: '0000.00000',
              description: 'test',
              georisques_id: 'P/7/8acb340164a854b40164a870a77a0047',
              installation_id: installation.id)
  end
  let!(:prescription) do
    Prescription.create(reference: 'Article 1 AP', content: "Contenu de l'article 1", ap_id: ap.id,
                        user_id: user.id)
  end
  let(:arrete) { FactoryBot.create(:arrete, :classement_2521_E) }

  context 'on index' do
    it 'displays am and ap prescriptions' do
      session[:user_id] = user.id

      get :index, params: { id: installation.id, arrete_ids: [arrete.id], arrete_types: [Arrete] }

      # AM
      assert_select 'li.glide__slide a[href=?]', "#anchor_am_#{arrete.id}",
                    { count: 1, text: 'Arrêté du 9 avril 2019' }
      assert_select "#anchor_am_#{arrete.id}_summary a[href=?]",
                    "#anchor_#{arrete.summary['elements'].first['section_id']}",
                    { count: 1, text: 'Chapitre Ier : Dispositions générales' }
      assert_select "section#anchor_am_#{arrete.id} label",
                    /classées soumises à enregistrement sous la rubrique n° 2521./, count: 1

      # AP
      assert_select 'li.glide__slide a[href=?]', "#anchor_ap_#{ap.id}", { count: 1, text: 'test' }
      assert_select "#anchor_ap_#{ap.id}_summary a[href=?]", "#anchor_ap_#{ap.id}",
                    { count: 1, text: 'Article 1 AP' }
      assert_select "section#anchor_ap_#{ap.id} label",
                    { count: 1, text: "Contenu de l'article 1" }
    end

    it 'does not display ap prescriptions if the user is not the owner' do
      get :index, params: { id: installation.id, arrete_ids: [arrete.id], arrete_types: [Arrete] }

      # AM
      assert_select 'li.glide__slide a[href=?]', "#anchor_am_#{arrete.id}",
                    { count: 1, text: 'Arrêté du 9 avril 2019' }
      assert_select "#anchor_am_#{arrete.id}_summary a[href=?]",
                    "#anchor_#{arrete.summary['elements'].first['section_id']}",
                    { count: 1, text: 'Chapitre Ier : Dispositions générales' }
      assert_select "section#anchor_am_#{arrete.id} label",
                    /classées soumises à enregistrement sous la rubrique n° 2521./, count: 1

      # AP
      assert_select 'li.glide__slide a[href=?]', "#anchor_ap_#{ap.id}", { count: 0, text: 'test' }
      assert_select "#anchor_ap_#{ap.id}_summary a[href=?]", "#anchor_ap_#{ap.id}",
                    { count: 0, text: 'Article 1 AP' }
      assert_select "section#anchor_ap_#{ap.id} label",
                    { count: 0, text: "Contenu de l'article 1" }
    end

    it 'displays ap and prescriptions from original installation if installation is duplicated' do
      session[:user_id] = user.id
      installation.duplicate!(user)

      get :index, params: { id: Installation.last.id, arrete_ids: [arrete.id], arrete_types: [Arrete] }

      assert_select "section#anchor_ap_#{ap.id} label", { count: 1, text: "Contenu de l'article 1" }
    end
  end
end

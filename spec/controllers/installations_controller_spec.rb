# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstallationsController, type: :controller do
  render_views

  let(:installation) { Installation.create(name: 'Installation test', s3ic_id: '0000.00000') }

  context 'on #index' do
    it 'creates a user and a session id on first visit' do
      expect do
        get :index
      end.to change { User.count }.from(0).to(1)

      expect(session[:user_id]).to eq User.last.id
    end

    it 'creates a user and recreate a session id if there is an isolate session id' do
      session[:user_id] = 1
      expect do
        get :index
      end.to change { User.count }.from(0).to(1)
      expect(session[:user_id]).to eq User.last.id
    end

    it 'retrieve session and user' do
      user1 = User.create
      User.create
      session[:user_id] = user1.id
      expect do
        get :index
      end.to change { User.count }.by(0)
      expect(session[:user_id]).to eq user1.id
    end
  end

  context 'on #edit' do
    it 'duplicates installation and redirects to edit' do
      installation

      expect do
        get :edit, params: { id: installation.id }
      end.to change { Installation.count }.from(1).to(2)

      expect(Installation.last.duplicated_from_id).to eq installation.id
      expect(Installation.last.name).to eq installation.name
      expect(Installation.last.user_id).to eq User.last.id

      expect(response).to redirect_to(edit_installation_path(Installation.last))
    end

    it 'works as a regular edit action if user want to edit an installation he created' do
      get :edit, params: { id: installation.id }

      expect do
        get :edit, params: { id: Installation.last.id }
      end.to change { Installation.count }.by(0)

      expect(response).to have_http_status(:ok)
    end

    it 'redirects to duplicated installation edit if user has already a copy
        and try to edit the original from direct url access' do
      get :edit, params: { id: installation.id }

      expect do
        get :edit, params: { id: installation.id }
      end.to change { Installation.count }.by(0)

      expect(response).to redirect_to(edit_installation_path(Installation.last))
    end
  end

  context 'on #show' do
    it 'displays prescriptions count only if the user owns the prescriptions' do
      user = User.create

      ap = AP.create(installation_s3ic_id: '0000.00000', description: 'test', georisques_id: 'P/7/8acb340164a854b40164a870a77a0047',
                     installation_id: installation.id)
      Prescription.create(reference: 'Article 1', content: "Contenu de l'article 1", ap_id: ap.id, user_id: user.id)

      get :show, params: { id: installation.id }

      assert_select 'a[href=?]', "/installations/#{installation.id}/aps/#{ap.id}", { count: 1, text: 'test -' }
      assert_select 'small', { count: 0, text: '- 1 prescription(s)' }

      session[:user_id] = user.id
      get :show, params: { id: installation.id }

      assert_select 'a[href=?]', "/installations/#{installation.id}/aps/#{ap.id}", { count: 1, text: 'test -' }
      assert_select 'small', { count: 1, text: '- 1 prescription(s)' }
    end

    it 'displays ap from original installation if installation is duplicated' do
      user = User.create
      ap = AP.create(installation_s3ic_id: '0000.00000', description: 'test', georisques_id: 'P/7/8acb340164a854b40164a870a77a0047',
                     installation_id: installation.id)
      installation.duplicate!(user)

      get :show, params: { id: installation.id }

      assert_select 'a[href=?]', "/installations/#{installation.id}/aps/#{ap.id}", { count: 1, text: 'test -' }
    end
  end
end

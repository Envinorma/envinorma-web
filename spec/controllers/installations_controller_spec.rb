# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstallationsController, type: :controller do
  render_views

  let(:installation) { Installation.create(name: 'Installation test', s3ic_id: '0000.00000') }

  context 'on #index' do
    it "creates a user and a session id on first visit" do
      expect do
        get :index
      end.to change { User.count }.from(0).to(1)

      expect(session[:user_id]).to eq User.last.id
    end

    it "creates a user and recreate a session id if there is an isolate session id" do
      session[:user_id] = 1
      expect do
        get :index
      end.to change { User.count }.from(0).to(1)
      expect(session[:user_id]).to eq User.last.id
    end

    it "retrieve session and user" do
      user_1 = User.create
      user_2 = User.create
      session[:user_id] = user_1.id
      expect do
        get :index
      end.to change { User.count }.by(0)
      expect(session[:user_id]).to eq user_1.id
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
    it 'displays content show' do
      ap = AP.create(installation_s3ic_id: '0000.00000', description: "test", url: 'http://documents.installationsclassees.developpement-durable.gouv.fr/commun/P/7/8acb340164a854b40164a870a77a0047.pdf',
          installation_id: installation.id)

      get :show, params: { id: installation.id }

      assert_select "a[href=?]", "/installations/#{installation.id}/aps/#{ap.id}", { :count => 1, :text => 'test -' }
    end

    it 'displays ap from original installation if installation is duplicated' do
      ap = AP.create(installation_s3ic_id: '0000.00000', description: "test", url: 'http://documents.installationsclassees.developpement-durable.gouv.fr/commun/P/7/8acb340164a854b40164a870a77a0047.pdf',
          installation_id: installation.id)
      get :edit, params: { id: installation.id }

      get :show, params: { id: installation.id }

      assert_select "a[href=?]", "/installations/#{installation.id}/aps/#{ap.id}", { :count => 1, :text => 'test -' }
    end
  end
end

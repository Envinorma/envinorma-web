require 'rails_helper'

RSpec.describe InstallationsController, type: :controller do

  context "on #edit" do
    it "creates a user if no user is set, duplicates installation and redirects to edit" do
      installation = Installation.create(name: "Installation test")
      expect {
        get :edit, params: {id: installation.id }
      }.to change{User.count}.from(0).to(1)
       .and change{Installation.count}.from(1).to(2)

      expect(session[:user_id]).to eq User.last.id

      expect(Installation.last.duplicated_from_id).to eq installation.id
      expect(Installation.last.name).to eq installation.name
      expect(Installation.last.user_id).to eq User.last.id

      expect(response).to redirect_to(edit_installation_path(Installation.last))
    end

    it "works as a regular edit action if user want to edit an installation he created" do
      installation = Installation.create(name: "Installation test")
      get :edit, params: {id: installation.id }

      expect {
        get :edit, params: {id: Installation.last.id }
      }.to change{User.count}.by(0)
       .and change{Installation.count}.by(0)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to duplicated installation edit if user has already a copy and try to edit the original from direct url access" do
      installation = Installation.create(name: "Installation test")
      get :edit, params: {id: installation.id }

      expect {
        get :edit, params: {id: installation.id }
      }.to change{Installation.count}.by(0)

      expect(response).to redirect_to(edit_installation_path(Installation.last))
    end
  end
end

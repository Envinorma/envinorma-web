require 'rails_helper'

RSpec.describe InstallationsController, type: :controller do

  context "on #edit" do
    it "creates a user if no user is set" do
      Installation.create(name: "Installation test")
      expect {
        get :edit, params: {"id"=>"1"}
      }.to change{User.count}.from(0).to(1)
      # expect(response.body).to(include()
    end

    xit "duplicates the installation and redirects to edit page" do
    end

    xit "does not duplicates the installation if user created the installation" do
    end
  end

end

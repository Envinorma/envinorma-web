# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleExpectations
RSpec.describe InstallationsController, type: :controller do
  context 'when #edit' do
    it 'works as a regular edit action if user want to edit an installation he created' do
      user = User.create
      cookies[:user_id] = user.id
      Installation.create(name: 'Installation test', s3ic_id: '0000.00000', user_id: user.id)
      get :edit, params: { id: Installation.last.id }

      expect(response).to render_template(:edit)
    end

    it 'redirects to homepage if user tries to edit an installation he has not created' do
      user = User.create
      cookies[:user_id] = user.id
      Installation.create(name: 'Installation test', s3ic_id: '0000.00000')
      get :edit, params: { id: Installation.last.id }

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when #create' do
    it 'create a copy of an existing installation if an id is passed in params' do
      installation = Installation.create(name: 'Installation test', s3ic_id: '0000.00000')

      expect do
        get :create, params: { id: installation.id }
      end.to change(Installation, :count).from(1).to(2)

      expect(cookies[:user_id]).to eq User.last.id.to_s

      expect(Installation.last.duplicated_from_id).to eq installation.id
      expect(Installation.last.name).to eq installation.name
      expect(Installation.last.user_id).to eq User.last.id

      expect(response).to redirect_to(installation_path(Installation.last))
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations

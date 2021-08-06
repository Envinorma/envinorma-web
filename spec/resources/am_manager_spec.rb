# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AMManager do
  context 'when #validate_then_recreate' do
    it 'creates the AM if inexistent' do
      am_filename = Rails.root.join('spec/fixtures/ams/JORFTEXT000038358856.json')

      expect do
        described_class.validate_then_recreate([am_filename])
      end.to change(AM, :count).from(0).to(1)
    end

    it 'replaces the AM without changing the value of content_updated_at if AM has same content' do # rubocop:disable RSpec/MultipleExpectations
      am = FactoryBot.create(:am, :classement_2521_E)
      am.update!(date_of_signature: '2021-01-01'.to_date)
      am_filename = Rails.root.join('spec/fixtures/ams/JORFTEXT000038358856.json')
      described_class.validate_then_recreate([am_filename])
      old_content_updated_at = am.content_updated_at
      old_date_of_signature = am.date_of_signature
      new_am = AM.first
      expect(new_am.content_updated_at).to eq(old_content_updated_at)
      expect(new_am.date_of_signature).not_to eq(old_date_of_signature)
    end

    it 'replaces the AM with the value of content_updated_at if AM has different content' do # rubocop:disable RSpec/MultipleExpectations
      am = FactoryBot.create(:am, :classement_2521_E)
      am.update!(date_of_signature: '2021-01-01'.to_date, title: 'New long title')
      am_filename = Rails.root.join('spec/fixtures/ams/JORFTEXT000038358856.json')
      described_class.validate_then_recreate([am_filename])
      old_content_updated_at = am.content_updated_at
      old_date_of_signature = am.date_of_signature
      new_am = AM.first
      expect(new_am.content_updated_at).not_to eq(old_content_updated_at)
      expect(new_am.date_of_signature).not_to eq(old_date_of_signature)
    end

    it 'deletes the AM if not present in new AMs files' do
      FactoryBot.create(:am, :classement_2521_E)
      described_class.validate_then_recreate([])
      expect(AM.count).to eq(0)
    end

    it 'deletes the AM and associated prescriptions if not present in new AMs files' do
      FactoryBot.create(:am, :classement_2521_E)
      User.create!(id: 1)
      Installation.create!(id: 1, name: 'name', s3ic_id: '0000.00000')
      Prescription.create!(alinea_id: '0', content: 'content', from_am_id: AM.first.id, user_id: 1, installation_id: 1)
      Prescription.create!(alinea_id: '1', content: 'content', from_am_id: nil, user_id: 1, installation_id: 1)
      Prescription.create!(alinea_id: '2', content: 'content', from_am_id: AM.first.id + 1,
                           user_id: 1, installation_id: 1)
      expect do
        described_class.validate_then_recreate([])
      end.to change(Prescription, :count).from(3).to(2)
    end
  end

  context 'when #same_content?' do
    it 'returns true when called with the same empty AM' do
      am = AM.new(title: 'title', data: { sections: [] })
      expect(described_class).to be_same_content(am, am)
    end

    it 'returns true when called with the same AM with one section' do
      section = { title: { text: 'section 1' }, outer_alineas: [{ text: 'alineas', table: nil }], sections: [] }
      am = AM.new(title: 'title', data: { sections: [section] })
      expect(described_class).to be_same_content(am, am)
    end

    it 'returns true when called with the same AM with one table' do
      table = { text: nil, table: { rows: [{ cells: [{ content: { text: 'cell 1' } }] }] } }
      section = { title: { text: 'section 1' }, outer_alineas: [table], sections: [] }
      am = AM.new(title: 'title', data: { sections: [section] })
      expect(described_class).to be_same_content(am, am)
    end

    it 'returns true when called with the same AM with one table in a section of depth 2' do
      table = { text: nil, table: { rows: [{ cells: [{ content: { text: 'cell 1' } }] }] } }
      subsection = { title: { text: 'section 1.1' }, outer_alineas: [table], sections: [] }
      section = { title: { text: 'section 1' }, outer_alineas: [], sections: [subsection] }
      am = AM.new(title: 'title', data: { sections: [section] })
      expect(described_class).to be_same_content(am, am)
    end

    it 'returns true when called with the same AM' do
      am = FactoryBot.create(:am, :classement_2521_E)
      expect(described_class).to be_same_content(am, am)
    end

    it 'returns false when called with different content in one table cell' do
      am1 = FactoryBot.create(:am, :classement_2521_E)
      am2 = FactoryBot.create(:am, :classement_2521_E)
      target_section = am2.data.sections[4].sections[2].sections[2]
      target_section.outer_alineas[2].table.rows[0].cells[0].content.text = 'New content'
      expect(described_class).not_to be_same_content(am1, am2)
    end

    it 'returns false when called with ams having different title in one section' do
      am1 = FactoryBot.create(:am, :classement_2521_E)
      am2 = FactoryBot.create(:am, :classement_2521_E)
      am1.data.sections[4].sections[2].sections[2].title.text = 'New title'
      expect(described_class).not_to be_same_content(am1, am2)
    end

    it 'returns false when called with ams having different title ' do
      am = FactoryBot.create(:am, :classement_2521_E)
      am_copy = am.dup
      am_copy.title = 'New title'
      expect(described_class).not_to be_same_content(am, am_copy)
    end
  end
end

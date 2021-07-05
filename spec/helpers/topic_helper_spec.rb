# frozen_string_literal: true

require 'rails_helper'

require './app/helpers/topic_helper'

RSpec.configure do |c|
  c.include TopicHelper
end

RSpec.describe TopicHelper do
  describe 'section_topics' do
    it 'maps section id to topic if section has topic' do
      section = OpenStruct.new({ id: 'section', annotations: OpenStruct.new({ topic: 'DECHETS' }),
                                 sections: [] })
      expect(section_topics(section, nil)).to eq({ 'section' => ['DECHETS'] })
    end

    it 'maps section id to ascendant topic if section has no topic' do
      section = OpenStruct.new({ id: 'section', annotations: OpenStruct.new({ topic: nil }), sections: [] })
      expect(section_topics(section, 'DECHETS')).to eq({ 'section' => ['DECHETS'] })
    end

    it 'maps child section id to ascendant topic' do
      subsection = OpenStruct.new({ id: 'subsection', annotations: OpenStruct.new({ topic: nil }), sections: [] })
      section = OpenStruct.new({ id: 'section', annotations: OpenStruct.new({ topic: 'DECHETS' }),
                                 sections: [subsection] })
      expected = { 'section' => ['DECHETS'], 'subsection' => ['DECHETS'] }
      expect(section_topics(section, 'DECHETS')).to eq(expected)
    end

    it 'maps children topics to parent section id' do
      subsection1 = OpenStruct.new({ id: 'subsection1', annotations: OpenStruct.new({ topic: 'DECHETS' }),
                                     sections: [] })
      subsection2 = OpenStruct.new({ id: 'subsection2', annotations: OpenStruct.new({ topic: 'EAU' }), sections: [] })
      section = OpenStruct.new({ id: 'section', annotations: OpenStruct.new({ topic: nil }),
                                 sections: [subsection1, subsection2] })
      expected = { 'section' => %w[DECHETS EAU], 'subsection1' => ['DECHETS'], 'subsection2' => ['EAU'] }
      expect(section_topics(section, nil)).to eq(expected)
    end
  end
end

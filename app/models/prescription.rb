# frozen_string_literal: true

class Prescription < ApplicationRecord
  include TopicHelper

  belongs_to :user
  belongs_to :installation

  validates :alinea_id, uniqueness: { scope: %i[installation_id user_id] }, if: :from_am?

  def from_am?
    type == 'AM'
  end

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def text_date
    date_string = text_reference[%r/[0-9]{2}\/[0-9]{2}\/[0-9]{2}/]

    return nil if date_string.nil?

    Date.strptime(date_string, '%d/%m/%y')
  rescue Date::Error
    nil
  end

  def human_type
    from_am? ? 'Arrêté Ministériel' : 'Arrêté Préfectoral'
  end

  def rank_array
    rank.nil? ? [] : rank.split('.').map(&:to_i)
  end

  def table
    raise 'Cannot read table' unless is_table?

    JSON.parse(content, object_class: OpenStruct)
  end

  def human_readable_table_content
    return nil unless is_table?

    table.rows.map { |row| row.cells.map(&:content).map(&:text).join("\t") }.join("\n")
  end

  def human_readable_content
    return content unless is_table?

    human_readable_table_content
  end

  def human_topic
    topic == TopicHelper::AUCUN ? '' : TOPICS[topic]
  end

  def full_reference
    [reference, name].compact.join(' - ')
  end

  def reference_number
    return nil unless reference

    number = reference
    %w[article annexe].each do |prefix|
      number = number[prefix.size..].strip if number.downcase.starts_with?(prefix)
    end
    number
  end
end

# frozen_string_literal: true

module SearchHelper
  def split_sentence_on_last_space(sentence)
    return [sentence, ''] if sentence.count(' ').zero?

    *first_words_, last_word = sentence.split
    first_words = first_words_.join(' ')
    [(first_words || ''), (last_word || '')]
  end

  def build_query(user_input)
    first_words, last_word = split_sentence_on_last_space(user_input.downcase)

    query = 'name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?'
    if last_word.nil? || last_word.empty?
      args = [query] + Array.new(4, "%#{first_words}%")
    else
      and_query = "(#{query}) and (#{query})"
      args = [and_query] + Array.new(4, "%#{first_words}%") + Array.new(4, "%#{last_word}%")
    end
    args
  end
end

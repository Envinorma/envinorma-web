# frozen_string_literal: true

module SearchHelper
  def build_query(user_input)
    first_words, last_word = split_sentence_on_last_space(user_input.downcase)

    query = 'name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?'
    nb_query_vars = 4
    if last_word.nil? || last_word.empty?
      args = [query] + Array.new(nb_query_vars, "%#{first_words}%")
    else
      and_query = "(#{query}) and (#{query})"
      args = [and_query] + Array.new(nb_query_vars, "%#{first_words}%") + Array.new(nb_query_vars, "%#{last_word}%")
    end
    args
  end

  private

  def split_sentence_on_last_space(sentence)
    return [sentence, ''] if sentence.count(' ').zero?

    *first_words, last_word = sentence.split
    sentence_begin = first_words.join(' ')
    [(sentence_begin || ''), (last_word || '')]
  end
end

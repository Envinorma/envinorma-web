# frozen_string_literal: true

class Date
  def to_timestamp
    to_datetime&.to_i
  end
end

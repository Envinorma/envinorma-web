# frozen_string_literal: true

module OpenStructHelper
  def open_struct_to_hash(object, hash = {})
    object.each_pair do |key, value|
      hash[key] = case value
                  when OpenStruct then open_struct_to_hash(value)
                  when Array then value.map { |v| open_struct_to_hash(v) }
                  else value
                  end
    end
    hash
  end
end

# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class BatchOperations
  def self.validate_batch(model, hash_batch)
    hash_batch.each do |hash|
      object = model.new(hash)

      raise "error validations #{object.inspect} #{object.errors.full_messages}" unless object.validate
    end
  end

  def self.upsert_batch(model, hash_batch)
    # Here, we use insert_all and update_all for benefitting from bulk operation performances
    # Validation is not done, and must be handled separately
    hashes_to_insert, hashes_to_update = hash_batch.partition { |hash| hash[:id].nil? }
    # rubocop:disable Rails/SkipsModelValidations
    inserted_ids = hashes_to_insert.empty? ? [] : model.insert_all(hashes_to_insert)
    updated_ids = hashes_to_update.empty? ? [] : model.upsert_all(hashes_to_update)
    # rubocop:enable Rails/SkipsModelValidations
    Rails.logger.info "......inserted #{inserted_ids.length} new #{model}s."
    Rails.logger.info "......updated #{updated_ids.length} #{model}s."
    missing_upsertions = hash_batch.length - (inserted_ids.length + updated_ids.length)
    Rails.logger.info "Warning: #{missing_upsertions} #{model}s were not upserted!" unless missing_upsertions.zero?
  end
end

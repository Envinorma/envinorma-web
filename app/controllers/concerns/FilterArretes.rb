# frozen_string_literal: true

module FilterArretes
  extend ActiveSupport::Concern

  included do
    helper_method :filter_arretes
  end

  def filter_arretes(arrete_reference, arretes_list)
    arretes_list.select do |arrete|
      classement = Classement.find (@installation.classements.pluck(:id) & arrete_reference.classements.pluck(:id)).first
      date_left = arrete.installation_date_criterion_left
      date_right = arrete.installation_date_criterion_right

      if classement.date_autorisation.nil?
        if arrete.unique_version
          arrete
        elsif date_left.nil? && date_right.nil?
          arrete
        end
      else
        next if !arrete.unique_version && date_left.nil? && date_right.nil?

        if arrete.unique_version
          arrete
        elsif date_left.present? && date_right.present?
          if date_left.to_date <= classement.date_autorisation && date_right.to_date > classement.date_autorisation
            arrete
          end
        elsif date_left.present?
          arrete if date_left.to_date < classement.date_autorisation
        elsif date_right.to_date >= classement.date_autorisation
          arrete
        end
      end
    end
  end
end

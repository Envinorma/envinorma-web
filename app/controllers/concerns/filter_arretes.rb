# frozen_string_literal: true

module FilterArretes
  extend ActiveSupport::Concern

  included do
    helper_method :filter_arretes
  end

  def filter_arretes(arrete_reference, enriched_arretes)
    enriched_arretes.select do |arrete|

      # get the classement comparing installation classements and arrete unique_classements
      # empty date classement if multiples classements
      common_classements = arrete_reference.unique_classements.pluck(:rubrique, :regime) & @installation.classements.pluck(:rubrique, :regime)
      if common_classements.count > 1
        common_classement = common_classements.first
        classement = @installation.classements.where(rubrique: common_classement[0] , regime: common_classement[1]).first
        classement.date_autorisation = nil
      else
        common_classement = common_classements.first
        classement = @installation.classements.where(rubrique: common_classement[0] , regime: common_classement[1]).first
      end

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

# frozen_string_literal: true

module FilterArretes
  extend ActiveSupport::Concern

  included do
    helper_method :filter_arretes
  end

  def filter_arretes_with_date(enriched_arretes, date_autorisation)
    found_arretes = []
    enriched_arretes.each do |arrete|
      date_left = arrete.installation_date_criterion_left
      date_right = arrete.installation_date_criterion_right
      
      if date_autorisation.nil?
        # We keep only the no-date arrete
        if arrete.unique_version || (date_left.nil? && date_right.nil?) 
          found_arretes << arrete
        end
      else
        next if !arrete.unique_version && date_left.nil? && date_right.nil?
        
        if arrete.unique_version
          found_arretes << arrete
        elsif date_left.present? && date_right.present?
          if date_left.to_date <= date_autorisation && date_right.to_date > date_autorisation
            found_arretes << arrete
          end
        elsif date_left.present?
          found_arretes << arrete if date_left.to_date < date_autorisation
        elsif date_right.to_date >= date_autorisation
          found_arretes << arrete
        end
      end
    end
    found_arretes
  end

  def filter_arretes(arrete_reference, enriched_arretes, installation)
      # get the classement comparing installation classements and arrete unique_classements
      # empty date classement if multiples classements
      common_classements = arrete_reference.unique_classements.pluck(:rubrique, :regime) & installation.classements.pluck(:rubrique, :regime)
      if common_classements.count > 1
        date_autorisation = nil
      else
        common_classement = common_classements.first
        classement = installation.classements.where(rubrique: common_classement[0] , regime: common_classement[1]).first
        date_autorisation = classement.date_autorisation
      end
      filter_arretes_with_date(enriched_arretes, date_autorisation)
  end
end

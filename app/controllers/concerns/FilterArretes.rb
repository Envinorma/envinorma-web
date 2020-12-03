module FilterArretes
  extend ActiveSupport::Concern

  included do
    helper_method :filter_arretes
  end

  def filter_arretes
    @installation.arretes.select do |arrete|
      classement = Classement.where(arrete_id: arrete.id, installation_id: @installation.id).first
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
          arrete if date_left.to_date <= classement.date_autorisation && date_right.to_date > classement.date_autorisation
        elsif date_left.present?
          arrete if date_left.to_date < classement.date_autorisation
        else
          arrete if date_right.to_date >= classement.date_autorisation
        end
      end
    end
  end
end

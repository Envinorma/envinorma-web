module FilterArretes
  extend ActiveSupport::Concern

  included do
    helper_method :filter_arretes
  end

  def filter_arretes
    arretes = filter_arretes_by_rubrique
    filter_arretes_by_date arretes
  end

  def filter_arretes_by_rubrique
    arretes = @installation.arretes
    # arretes = Arrete.all.select do |arrete|
    #   # à garder pour comparer également le régime
    #   # compare_array(arrete, :rubrique) && compare_array(arrete, :regime)
    #   (arrete.data.classements.pluck(:rubrique) & @installation.classements.pluck(:rubrique)).any?
    # end
  end

  def filter_arretes_by_date arretes
    arretes = arretes.reverse.select do |arrete|
      date_left = arrete.installation_date_criterion_left
      date_right = arrete.installation_date_criterion_right

      if @installation.date.nil?
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
          arrete if date_left.to_date <= @installation.date && date_right.to_date > @installation.date
        elsif date_left.present?
          arrete if date_left.to_date < @installation.date
        else
          arrete if date_right.to_date >= @installation.date
        end
      end
    end
  end

  def compare_array arrete, element
    (arrete.data.classements.pluck(element) & @installation.classements.pluck(element)).any?
  end
end

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
    arretes_filtered = []
    arretes.each do |arrete|
      installation_date_criterion = arrete.data.installation_date_criterion
      if @installation.date.nil?
        if arrete.data.unique_version
          arretes_filtered << arrete
        elsif installation_date_criterion.nil?
          arretes_filtered << arrete
        end
      else
        next if !arrete.data.unique_version && installation_date_criterion.nil?
        if arrete.data.unique_version
          arretes_filtered << arrete
        elsif installation_date_criterion.left_date.present? && installation_date_criterion.right_date.present?
          arretes_filtered << arrete if installation_date_criterion.left_date.to_date <= @installation.date && installation_date_criterion.right_date.to_date > @installation.date
        elsif installation_date_criterion.left_date.present?
          arretes_filtered << arrete if installation_date_criterion.left_date.to_date < @installation.date
        else
          arretes_filtered << arrete if installation_date_criterion.right_date.to_date >= @installation.date
        end
      end
    end
    arretes_filtered
  end

  def compare_array arrete, element
    (arrete.data.classements.pluck(element) & @installation.classements.pluck(element)).any?
  end
end

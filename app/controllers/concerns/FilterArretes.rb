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
    arretes_filtered = []
    Arrete.all.each do |arrete|
      if compare_array(arrete, :rubrique) && compare_array(arrete, :regime)
        arretes_filtered << arrete
      end
    end
    arretes_filtered
  end

  def filter_arretes_by_date arretes
    arretes_filtered = []
    arretes.each do |arrete|
      installation_date_criterion = arrete.data.installation_date_criterion
      if installation_date_criterion.nil?
        arretes_filtered << arrete
      elsif installation_date_criterion.left_date.present? && installation_date_criterion.right_date.present?
        arretes_filtered << arrete if installation_date_criterion.left_date.to_date <= @installation.date && installation_date_criterion.right_date.to_date > @installation.date
      elsif installation_date_criterion.left_date.present?
        arretes_filtered << arrete if installation_date_criterion.left_date.to_date < @installation.date
      else
        arretes_filtered << arrete if installation_date_criterion.right_date.to_date >= @installation.date
      end
    end
    arretes_filtered
  end

  def compare_array arrete, element
    (arrete.data.classements.pluck(element) & @installation.classements.pluck(element)).any?
  end
end

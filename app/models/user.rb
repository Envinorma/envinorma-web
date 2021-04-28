# frozen_string_literal: true

class User < ApplicationRecord
  has_many :installations, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  def prescription_exist?(installation, alinea_id)
    prescriptions.where(installation_id: installation.id).map(&:alinea_id).include?(alinea_id)
  end

  def prescriptions_for(installation)
    prescriptions.where(installation_id: installation.id)
  end

  def prescriptions_grouped_for(installation)
    group_prescriptions(prescriptions_for(installation))
  end

  private

  def group_prescriptions(prescriptions)
    FilterHelper.sort_and_group(prescriptions)
  end
end

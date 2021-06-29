# frozen_string_literal: true

class User < ApplicationRecord
  include PrescriptionsGroupingHelper

  has_many :installations, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  def prescription_alinea_ids(installation)
    prescriptions.where(installation_id: installation.id).map(&:alinea_id)
  end

  def prescriptions_for(installation)
    prescriptions.where(installation_id: installation.id)
  end

  def prescriptions_grouped_for(installation)
    group_prescriptions(prescriptions_for(installation))
  end

  def already_duplicated_installation?(installation)
    present? && installations.pluck(:duplicated_from_id).include?(installation.id)
  end

  def retrieve_duplicated_installation(installation)
    installations.find_by(duplicated_from_id: installation.id)
  end

  def toggle_grouping
    self.group_prescriptions_by_topic = !group_prescriptions_by_topic
    save
  end

  private

  def group_prescriptions(prescriptions)
    sort_and_group(prescriptions, group_prescriptions_by_topic)
  end
end

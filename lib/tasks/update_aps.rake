# frozen_string_literal: true

desc 'This tasks updates APs from OVH on a daily basis'

task update_aps: :environment do
  Rails.logger.info('Updating APs from OVH...')
  DataManager.update_aps(from_ovh: true, use_sample: false)
  Rails.logger.info('done.')
end

# frozen_string_literal: true

desc 'This tasks deletes users with no activity for 3 months'

task delete_old_users: :environment do
  User.where('updated_at < ?', 3.months.ago).destroy_all
end

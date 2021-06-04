web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
release: bundle exec rake db:migrate
# release: bundle exec rake db:migrate && bundle exec rake after_party:run
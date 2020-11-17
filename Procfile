web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
postdeploy: bundle exec rake db:migrate && bundle exec rake after_party:run

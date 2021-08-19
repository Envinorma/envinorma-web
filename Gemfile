# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use Slim for views
gem 'slim', '~> 3.0.6'
# Normalize makes browsers render all elements more consistently and in line with modern standards
gem 'normalize-rails', '~> 4.1', '>= 4.1.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Generates ODF files, given a template (.odt) and data, replacing tags
gem 'odf-report'

# SimpleForm made forms easy!
gem 'simple_form', '~> 5.0', '>= 5.0.3'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Automated post-deploy tasks for Ruby/Rails
gem 'after_party', '~> 1.11'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Sentry SDK for Ruby - Error tracking
gem 'sentry-rails'
gem 'sentry-ruby'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug', require: false
  # RSpec for Rails 5+
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 4.0.2'
  gem 'rubocop', '~> 1.10', require: false
  gem 'rubocop-rails', '~> 2.10.1', require: false
  gem 'rubocop-rspec', '~> 2.4.0', require: false
  gem 'slim_lint', '~> 0.20.2'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # BetterErrors provides a better error page
  gem 'better_errors', '~> 2.1', '>= 2.1.1'
  gem 'binding_of_caller', '~> 0.8.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'capybara-selenium'
  gem 'launchy'
  gem 'rack_session_access'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

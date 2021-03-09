# frozen_string_literal: true

require './spec/support/helpers/download_helper'

require 'selenium/webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
  end

  browser_options.add_preference(:download,
                                 { prompt_for_download: false, default_directory: DownloadHelpers::PATH.to_s })
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.javascript_driver = :selenium_chrome_headless

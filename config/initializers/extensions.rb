Dir[Rails.root.join('lib/extensions', '**', '*.rb')].map do |file|
  require file
end

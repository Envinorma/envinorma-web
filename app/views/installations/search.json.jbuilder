# frozen_string_literal: true

json.array!(@installations) do |installation|
  json.name "#{installation.s3ic_id} | #{installation.name} - #{installation.zipcode} #{installation.city}"
  json.link installation_url(installation)
end

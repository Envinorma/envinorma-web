json.array!(@installations) do |installation|
  json.name installation.name + ', ' + "#{installation.id}"
  json.link installation_url(installation)
end

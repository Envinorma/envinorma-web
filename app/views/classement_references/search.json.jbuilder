# frozen_string_literal: true

json.array!(@classement_references) do |classement|
  alinea_string = classement.alinea.present? ? " #{classement.alinea}" : ''
  json.name "#{classement.rubrique} #{classement.regime}#{alinea_string} - #{classement.description}"
  json.id classement.id
end

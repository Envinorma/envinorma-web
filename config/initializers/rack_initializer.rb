# frozen_string_literal: true

Rack::Utils.key_space_limit = 262_144 if Rack::Utils.respond_to?('key_space_limit=')

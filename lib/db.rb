# frozen_string_literal: true

require 'sequel'

module BBBot
  DB =
    if ENV['TIER'] == 'prod'
      Sequel.postgres(
        'bb-bot',
        user: 'TODO',
        password: 'TODO',
        host: 'localhost',
        port: 9090,
        max_connections: 10,
      )
    else
      Sequel.sqlite('dev.db')
    end
end

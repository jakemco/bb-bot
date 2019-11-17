# frozen_string_literal: true

require 'sequel'

module BBBot
  ##
  # all the database model classes. Schemas live in the migrations folder.
  #
  module Models
    ##
    # Represents a person looking for a game on a specific date. Also scoped to
    # a specific channel cause we have channels per game.
    #
    class LFG < Sequel::Model(DB[:lfg])
      def self.games(event, &block)
        self.where(channel_id: event.channel.id, &block)
      end

      def self.my_games(event)
        self.games(event).where(discord_id: event.author.id)
      end

      def to_s
        day = self.date.strftime('%a, %b %d %Y')
        "<@#{self.discord_id}> looking for a game on #{day}"
      end
    end
    LFG.unrestrict_primary_key
  end
end

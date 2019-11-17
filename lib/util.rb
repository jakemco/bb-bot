# frozen_string_literal: true

require 'date'

module BBBot
  ##
  # Helper methods for the bot
  #
  module Util
    def self.next_thursday
      date = Date.parse('thursday')
      date + (date > Date.today ? 0 : 7)
    end

    def self.date_or_default(date)
      if date.nil?
        BBBot::Util.next_thursday
      else
        self.date_parse(date)
      end
    end

    def self.date_parse(date)
      Date.parse(date)
    end

    def self.date_to_s(date)
      date.strftime('%a, %b %d %Y')
    end
  end
end

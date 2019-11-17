#!/usr/bin/env ruby
# frozen_string_literal: true

require 'awesome_print'
require 'discordrb'
require 'dotenv/load'
require 'sequel/core'

CHANNELS = ['looking_for_a_game', 'botspam'].freeze

# set up the database, check for latest migrations
require './lib/db.rb'
Sequel.extension :migration
Sequel::Migrator.check_current(BBBot::DB, File.join(__dir__, 'lib/migrations'))

require './lib/models.rb'
require './lib/util.rb'

# run the bot
bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

bot.command(
  :lfg,
  channels: CHANNELS,
  min_args: 0,
  max_args: 1,
) do |event, day|
  author_id = event.author.id
  channel_id = event.channel.id
  day = BBBot::Util.date_or_default(day)
  lfg = BBBot::Models::LFG[author_id, channel_id, day]
  if lfg.nil?
    # TODO: validate day is legit?
    lfg = BBBot::Models::LFG.create(
      discord_id: author_id,
      channel_id: channel_id,
      date: day,
    )

    event << lfg.to_s
    # TODO: print suggested opponents
    event << "I'll get right on that..."
  else
    event << "You're already listed for that day"
  end
end

bot.command(
  :list,
  channels: CHANNELS,
  min_args: 0,
  max_args: 1,
) do |event, day|
  lfgs =
    if day.nil?
      BBBot::Models::LFG.games(event) { date >= Date.today }
    else
      day = BBBot::Util.date_parse(day)
      BBBot::Models::LFG.games(event).where(date: day)
    end
  if lfgs.empty? && !day.nil?
    "No games on #{BBBot::Util.date_to_s(day)}"
  elsif lfgs.empty?
    'No upcoming games'
  else
    lfgs.each do |lfg|
      event << lfg.to_s
    end
    nil
  end
end

bot.command(
  :mine,
  channels: CHANNELS,
) do |event|
  mine = BBBot::Models::LFG.my_games(event) { date > Date.today }
  if mine.empty?
    'No upcoming games for you'
  else
    mine.each do |lfg|
      event << lfg.to_s
    end
    nil
  end
end

bot.command(
  :unlfg,
  channels: CHANNELS,
  min_args: 0,
  max_args: 1,
) do |event, day|
  game_to_remove = nil

  if !day.nil?
    day = BBBot::Util.date_parse(day)
    game_to_remove = BBBot::Models::LFG.my_games(event).where(date: day).first
  else
    mine = BBBot::Models::LFG.my_games(event) { date > Date.today }.all
    if mine.size == 1
      game_to_remove = mine.first
    elsif mine.size > 1
      event << 'Not sure which day you meant to delete, try passing in a date.'
    end
  end

  if !game_to_remove.nil?
    day = game_to_remove.date
    game_to_remove.destroy
    "Game on #{BBBot::Util.date_to_s(day)} removed"
  else
    'No game found to remove'
  end
end

bot.run

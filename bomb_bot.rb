require 'slack-ruby-client'
require 'dotenv'
require 'pg'
require 'picky'

require_relative 'lib/help'
require_relative 'lib/joke'
require_relative 'lib/leaderboard'
require_relative 'lib/parser'
require_relative 'lib/user'
require_relative 'lib/vote'

Dotenv.load

module BombBot
  Slack.configure do |config|
    config.token = ENV['SLACK_API_KEY']
  end

  Conn = PGconn.open(dbname: ENV['DB_NAME'], host: ENV['DB_HOST'], user: ENV['DB_USER'], password: ENV['DB_PASSWORD'])
  RTClient = Slack::RealTime::Client.new
  WebClient = Slack::Web::Client.new(user_agent: 'Slack Ruby Client/1.0')
  Command = /^bomb/

  RTClient.on :hello do
    puts 'Successfully connected.'
  end

  RTClient.on :message do |data|
    data.text.match(Command) do
      Parser.run(data)
    end
  end

  def self.run!
    RTClient.start!
  end
end

BombBot.run!

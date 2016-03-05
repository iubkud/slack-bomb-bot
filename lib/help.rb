module BombBot
  class Help
    def self.show(data)
      RTClient.message channel: data.channel, text: "bombbot Command List\n
        1. bomb \@username \"awesome joke here\" - adds joke\n
        2. bomb \@username - adds vote\n
        3. bomb -l --or-- bomb leaderboard - shows whos winning (losing)"
    end
  end
end

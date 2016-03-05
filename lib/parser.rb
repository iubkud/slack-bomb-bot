module BombBot
  class Parser
    attr_reader :data, :message, :user, :check_quote

    def initialize(data)
      @data = data
      @message = data.text.split(' ')
      @check_quote = message[2].to_s
    end

    def self.run(data)
      new(data).parse
    end

    def user
      @user = message[1].to_s
    end

    def parse
      if is_joke?
        Joke.add(data, user)
        Vote.add(data, user)
      elsif is_vote?
        Vote.add(data, user)
      elsif wants_leaderboard?
        Leaderboard.show(data)
      else
        Help.show(data)
      end
    end

    def is_joke?
      check_quote.match(/^\"/) && user.match(/^<@/)
    end

    def is_vote?
      !check_quote.match(/^\"/) && user.match(/^<@/)
    end

    def wants_leaderboard?
      data.text.match(/leaderboard/i) || data.text.match(/\-l/)
    end

    def self.get_formatted_date
      Time.now.strftime('%Y-%m-%d')
    end
  end
end

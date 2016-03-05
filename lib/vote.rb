module BombBot
  class Vote
    attr_reader :data, :user_id

    def initialize(data, user_id)
      @data = data
      @user_id = user_id
    end

    def self.add(data, user_id)
      new(data, user_id).add
    end

    def self.count_votes(user)
      Conn.exec("SELECT COUNT(*) FROM votes WHERE votefor = '#{user}'")
    end

    def author
      @author = User.find(user_id)
    end

    def voter
      @voter = User.find(data.user)
    end

    def add
      send_query
      message_channel
    end

    private

    def send_query
      Conn.prepare('add_vote', "insert into votes (votefor, voteby, date) values ($1, $2, $3)")
      Conn.exec_prepared('add_vote', [author.user.name, voter.user.name, Parser.get_formatted_date])
      Conn.exec('DEALLOCATE add_vote')
    end

    def message_channel
      RTClient.message channel: data.channel, text: "@#{voter.user.name} added one vote for @#{author.user.name}!"
    end
  end
end

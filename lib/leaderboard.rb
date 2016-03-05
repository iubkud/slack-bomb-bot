module BombBot
  class Leaderboard
    attr_reader :channel, :users, :ordered_vote_count

    def initialize(data)
      @channel = data.channel
    end

    def self.show(data)
      new(data).show
    end

    def users
      @users = RTClient.users.values.reject(&:deleted).map(&:name)
    end

    def ordered_vote_count
      vote_totals = {}
      users.each do |u|
        vote_totals[u] = Vote.count_votes(u).getvalue(0,0).to_i
      end
      @ordered_vote_count = vote_totals.sort_by{|k,v| v}.reverse.to_h
    end

    def show
      message = "bombboard leaderboard\n"
      ordered_vote_count.each do |user, votes|
        if votes > 0
          message << "\@#{user} : #{votes}\n"
        end
      end

      RTClient.message channel: channel, text: message
    end
  end
end
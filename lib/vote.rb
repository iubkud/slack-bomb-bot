module BombBot
  class Vote
    def self.count_votes(user)
      Conn.exec("SELECT COUNT(*) FROM votes WHERE votefor = '#{user}'")
    end

    def self.add(data, user_id)
      user_voted = User.find(user_id)
      user_voting = User.find(data.user)
      date = Parser.get_formatted_date

      Conn.prepare("add_vote", "insert into votes (votefor, voteby, date) values ($1, $2, $3)")
      Conn.exec_prepared("add_vote", [user_voted.user.name, user_voting.user.name, date])
      Conn.exec("DEALLOCATE add_vote")

      if (caller[0][/`.*'/][1..-2] != 'add_joke')
        RTClient.message channel: data['channel'], text: "@#{user_voting.user.name} added one vote for @#{user_voted.user.name}!"
      end
    end
  end
end
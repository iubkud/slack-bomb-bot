module BombBot
  class Joke
    attr_reader :data, :user_id

    def initialize(data, user_id)
      @data = data
      @user_id = user_id
    end

    def self.add(data, user_id)
      new(data, user_id).add
    end

    def user
      @user = User.find(user_id)
    end

    def joke
      @joke = data.text.scan(/"(.*?)"/).first.join
    end

    def add
      send_query
      message_channel
    end

    private

    def send_query
      Conn.prepare('insert_joke', 'insert into jokes (username, joke, date) values ($1, $2, $3)')
      Conn.exec_prepared('insert_joke', [user.user.name, joke, Parser.get_formatted_date])
      Conn.exec('DEALLOCATE insert_joke')
    end

    def message_channel
      RTClient.message channel: data.channel, text: "Added joke: \"#{joke}\""
    end
  end
end

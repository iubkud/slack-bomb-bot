module BombBot
  class User
    def self.find(data)
      clean_id = data.gsub(/<|>|@/, "")
      user = WebClient.users_info(user: clean_id)
    end
  end
end
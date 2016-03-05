require 'slack-ruby-client'
require 'dotenv'
require 'pg'
require 'picky'

Dotenv.load

@conn = PGconn.open(:dbname => 'bombboard')

Slack.configure do |config|
  config.token = ENV['SLACK_API_KEY']
end

@client = Slack::RealTime::Client.new
@web_client = Slack::Web::Client.new(user_agent: 'Slack Ruby Client/1.0')

@client.on :hello do
  puts 'Successfully connected.'
end

@client.on :message do |data|
  case data['text']
  when /^bomb/ then
  	check_msg(data)
  end
end

def check_msg(data)
	msg_array = data['text'].split(" ")
	check_quote = msg_array[2].to_s
	user_id = msg_array[1].to_s

	if ((check_quote.match(/^\"/)) && (user_id.match(/^<@/)) && (msg_array[0] == "bomb"))
		add_joke(data, user_id)
	elsif ((user_id.match(/^<@/)) && (msg_array[0] == "bomb"))
		add_vote(data, user_id)
	elsif ((data['text'].match(/leaderboard/i)) || (data['text'].match(/\-l/)))
		show_leaderboard(data)
	else
		send_help(data)
	end
end

def show_leaderboard(data)
	all_users = Array.new
	@client.users.each do |key, value|
  	all_users = @client.users.values.reject(&:deleted).map(&:name)
  end

  vote_totals = Hash.new
  all_users.each do |u|
  	# look up count
  	count = @conn.exec("SELECT COUNT(*) FROM votes WHERE votefor = '#{u}'")
  	# add count to 2d array
  	vote_totals[u] = count.getvalue(0,0).to_i
  end

  ordered_vote_count = vote_totals.sort_by{|k,v| v}.reverse.to_h

  msg_to_send = "bomboard leaderboard\n"
  ordered_vote_count.each do |user, votes|
  	if votes > 0
  		msg_to_send << "\@#{user} : #{votes}\n"
  	end
  end

  @client.message channel: data['channel'], text: "#{msg_to_send}"

end

def send_help(data)
	@client.message channel: data['channel'], text: "bombbot Command List\n
		1. bomb \@username \"awesome joke here\" - adds joke\n
		2. bomb \@username - adds vote\n
		3. bomb -l --or-- bomb leaderboard - shows whos winning (losing)"
end

def add_joke(data, user_id)
	stripped_joke = data['text'].scan(/"(.*?)"/)
	joke_to_add = stripped_joke.join
	date = get_formatted_date

	user = get_user_by_id(user_id)

	@conn.prepare("insert_joke", "insert into jokes (username, joke, date) values ($1, $2, $3)")
	@conn.exec_prepared("insert_joke", [user.user.name, joke_to_add, date])
	@conn.exec("DEALLOCATE insert_joke")

	add_vote(data, user_id)
	@client.message channel: data['channel'], text: "Added joke: \"#{joke_to_add}\""
end

# returns full user object, strips unwanted chars from UID
def get_user_by_id(info)
	clean_id = info.gsub(/<|>|@/, "")
	user = @web_client.users_info(user: clean_id)
	return user
end

def add_vote(data, user_id)
	user_voted = get_user_by_id(user_id)
	user_voting = get_user_by_id(data['user'])
	date = get_formatted_date

	@conn.prepare("add_vote", "insert into votes (votefor, voteby, date) values ($1, $2, $3)")
	@conn.exec_prepared("add_vote", [user_voted.user.name, user_voting.user.name, date])
	@conn.exec("DEALLOCATE add_vote")

	if (caller[0][/`.*'/][1..-2] != 'add_joke')
		@client.message channel: data['channel'], text: "@#{user_voting.user.name} added one vote for @#{user_voted.user.name}!"
	end
end

# format date YYYY-MM-DD
def get_formatted_date
	time = Time.new
	date = time.strftime("%Y-%m-%d")
	return date
end

@client.start!
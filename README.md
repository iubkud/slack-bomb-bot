# slack-bomb-bot

##Setup
You will need to create a new bot user on your Slack team. Once created, you will be given an API key. Create a .env file and add a line
`SLACK_API_KEY="your API key"`

Your Postgres database should be called `bombboard` with two tables `jokes` and `votes`

#####jokes has 4 columns

1. id - int, primary key, sequence
2. username - character
3. joke - character
4. date - date

#####votes has 3 columns

1. votefor - char
2. voteby - char
3. date - date



##To-Do
All sorts of things
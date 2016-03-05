# slack-bomb-bot

##Setup
###Slack
You will need to create a new bot user on your Slack team. Once created, you will be given an API key. Create an environment variable:
`SLACK_API_KEY="your API key"`

---
###Database
Set up your database env variables:
```
DB_NAME="[database-name]"
DB_HOST="[database-host"
DB_USER="[database-username]"
DB_PASSWORD="[database-password]"
```
Your Postgres database should have two tables `jokes` and `votes`

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
- [ ] Function to see who has voted the most
- [ ] Who has the most jokes logged
- [ ] Check to see who hates on who the most 
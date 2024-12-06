# X (Twitter) Reply Extractor

## 1. Introduction
This script allows you to search and extract replies to a specific tweet on X (formerly Twitter). You can filter the replies by keywords and/or hashtags, making it easier to find relevant responses.

## 2. Prerequisites

### Getting Your Bearer Token
1. Go to the [X Developer Portal](https://developer.x.com)
2. Sign in with your X account
3. Create a developer account
4. Apply for Basic access
5. Navigate to "Keys and Tokens"
6. Generate/Copy your Bearer Token


### Setting Up Environment
1. Create a `.env` file in the script directory
2. Add your Bearer Token:
```
TWITTER_BEARER_TOKEN=your_bearer_token_here
```

## 3. Usage

### Running the Script
1. Make the script executable:
```
chmod +x Xextract.sh
```

2. Run the script:
```
./Xextract.sh
```

### Search Options
The script will prompt you for:
- **Tweet ID**: The numeric ID of the tweet you want to analyze
- **Keyword** (optional): Filter replies containing specific words  
i.e. if you are looking for "great" as a keyword,
that will also lookt at some alternatives such as "great." or "great!"
- **Hashtag** (optional): Filter replies containing specific hashtags

### Output
The results will be:
- Displayed in the terminal
- Saved in `tweet_[ID]_data/formatted_replies.txt`
- Raw JSON response saved in `tweet_[ID]_data/replies.json`

## 4. Rate Limiting Notes
The script includes a built-in timer restriction to comply with X's API rate limits:
- Enforces a 15-minute waiting period between requests
- Displays remaining wait time if attempting to run too soon
- Helps prevent API rate limit errors
- Stores timestamp of last request in `tweet_[ID]_data/last_query_timestamp`

## Important Notes
- The Bearer Token provides access to public tweets only
- Search is limited to recent tweets (approximately 7 days)
- Rate limits apply as per X's API policies

#!/bin/bash
# Copyright (c) 2024 Acktarius
# All rights reserved.
#
# Licensed under the BSD 3-Clause License.
# See LICENSE file for details.
#filter tweets answer by word or hashtag

source .env

if [ -z "$TWITTER_BEARER_TOKEN" ]; then
    echo "Bearer token not found in .env file"
    exit 1
fi

read -p "Enter tweet ID: " tweet_id
read -p "Filter Tweet with keyword (press Enter to skip): " keyword
read -p "Filter Tweet by Hashtag (press Enter to skip): " hashtag

query="conversation_id:$tweet_id"
if [ ! -z "$keyword" ]; then
    # Add variations with common punctuation
    query="$query ($keyword OR \"$keyword!\" OR \"$keyword?\" OR \"$keyword.\")"
fi
[ ! -z "$hashtag" ] && query="$query #$hashtag"

output_dir="tweet_${tweet_id}_data"
mkdir -p "$output_dir"

# Define timestamp file
timestamp_file="$output_dir/last_query_timestamp"

# Check if timestamp file exists and if 15 minutes have passed
if [ -f "$timestamp_file" ]; then
    last_query=$(cat "$timestamp_file")
    current_time=$(date +%s)
    time_diff=$((current_time - last_query))
    
    if [ $time_diff -lt 900 ]; then  # 900 seconds = 15 minutes
        minutes_left=$(( (900 - time_diff) / 60 ))
        seconds_left=$(( (900 - time_diff) % 60 ))
        echo "Please wait ${minutes_left}m ${seconds_left}s before making another request"
        exit 1
    fi
fi

# Debug: Print the query being sent
echo "Searching with query: $query"

response=$(curl -s --request GET \
     --url "https://api.twitter.com/2/tweets/search/recent?query=$(echo $query | jq -sRr @uri)&tweet.fields=author_id,created_at,text&expansions=author_id&user.fields=username" \
     --header "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     --header 'Content-Type: application/json')

if echo "$response" | jq -e '.status == 429' >/dev/null; then
    echo "Rate limit hit. Please wait 15 minutes."
    date +%s > "$timestamp_file"
    exit 1
fi

if echo "$response" | jq -e '.errors' >/dev/null; then
    echo "Error from Twitter API:"
    echo "$response" | jq '.errors[].message'
    exit 1
elif echo "$response" | jq -e '.data' >/dev/null; then
    echo "$response" > "$output_dir/replies.json"
    # Save both to console and file
    cat "$output_dir/replies.json" | jq -r '
        .data[] as $tweet 
        | .includes.users[] as $user 
        | select($tweet.author_id == $user.id) 
        | "Name: \($user.name)\nUsername: @\($user.username)\nTweet: \($tweet.text)\n"
    ' | tee "$output_dir/formatted_replies.txt"
    # Create CSV output with headers and data
    echo "Name,Username,Tweet" > "$output_dir/CSV_formatted_replies.csv"
    cat "$output_dir/replies.json" | jq -r '
        .data[] as $tweet 
        | .includes.users[] as $user 
        | select($tweet.author_id == $user.id) 
        | [ $user.name, $user.username, $tweet.text ] 
        | @csv
    ' >> "$output_dir/CSV_formatted_replies.csv"
else
    echo "No replies found for this tweet ID with the given filters."
    echo "$response" > "$output_dir/replies.json"
fi

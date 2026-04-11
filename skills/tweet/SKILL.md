---
name: tweet
description: "Fetch and display any public X/Twitter post using the FixTweet API. Supports single tweets and threads. Triggers on: /tweet <url>"
argument-hint: "<tweet URL>"
user-invocable: true
context: fork
model: haiku
effort: low
allowed-tools:
  - WebFetch
  - WebSearch
memory: user
---

# Tweet — Fetch Public X/Twitter Posts

Fetch and display any public tweet using the free FixTweet API (`api.fxtwitter.com`).

## Usage

```
/tweet https://x.com/username/status/1234567890
```

## Workflow

### Step 1: Parse the URL

Extract the tweet path from the user-provided URL. The URL can be in any of these formats:

- `https://x.com/username/status/ID`
- `https://twitter.com/username/status/ID`
- `https://mobile.twitter.com/username/status/ID`
- Just a tweet ID (ask user for the full URL)

Extract `username` and `status ID` from the URL.

### Step 2: Fetch via FixTweet API

Replace the domain with `api.fxtwitter.com`:

```
WebFetch: https://api.fxtwitter.com/username/status/ID
```

Prompt for WebFetch: "Return the complete tweet content including: author name, handle, date, full tweet text, media descriptions (images/videos), engagement stats (likes, retweets, replies, views), and any quoted tweet content. Format as structured data."

### Step 3: Display the Tweet

Format the output as:

```markdown
## @handle — Name

**Date:** YYYY-MM-DD

> Tweet text here
> Can be multiple lines

**Media:** [description of any images/videos if present]
**Engagement:** X likes · Y retweets · Z replies · W views

[If there's a quoted tweet, show it indented]
```

### Step 4: Thread Detection

If the tweet is a reply or part of a thread, check if there's a `replying_to` field. If so, offer to fetch the parent tweet too.

## Error Handling

- If FixTweet returns an error or empty response, fall back to WebSearch: `site:x.com "username" "key phrase from URL"`
- If the tweet is from a private/protected account, inform the user that only public tweets are accessible
- If the URL format is unrecognized, ask the user to provide a valid tweet URL

## Examples

```
User: /tweet https://x.com/elonmusk/status/123456789

## @elonmusk — Elon Musk

**Date:** 2026-02-10

> Example tweet text here

**Engagement:** 50K likes · 10K retweets · 5K replies · 2M views
```

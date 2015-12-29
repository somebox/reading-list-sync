# Add Safari Reading List Bookmarks to Pinboard Unread List

Pinboard is great, but the integration into iOS and Mac can be annoying. Too many steps: copy and paste a url into the browser, click the Pinboard bookmarklet, enter tags, etc. On mobile, it's even more steps, and even harder to do.

This ruby script automates moving your Reading List bookmarks to Pinboard's "to read" list. It is meant to be run via a scheduled job (with launchd). 

The script works like so:

1. read all Safari bookmarks in the "Reading List"
2. check each to see if the url already exists on pinboard
3. add the bookmarks on Pinboard

If a Reading List bookmark exists on Pinboard and has no tags, the script will generate some using Pinboard's suggestions, matching tags you already have, plus some custom rules. 

For bookmarks older than 90 days (adjustable), it will sync the bookmark but disable the "toread" flag on Pinboard.

It should be safe to re-run this script over and over without harm. You can clear out your Safari Reading List bookmarks and the posts will remain on Pinboard.

## Setup

You need Ruby, and bundler, etc:

    $ rvm install ruby 2.2
    $ gem install bundler
    $ bundle
    $ cp config/secrets_example.yml config/secrets.yml

Edit the file `config/secrets.yml` and replace the value of `pinboard_api_key` with your [actual Pinboard API key](https://pinboard.in/settings/password).

## Usage

To run directly:

    $ script/sync_bookmarks

To schedule this as job with launchd, use the sample xml config 

    # TODO

## Benefits

When you are using iOS, or any mac, and you "add to reading list", the bookmark will appear on Pinboard, with tags. This allows you to keep using Pinboard (even via RSS) to keep up with your reading.

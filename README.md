Shellify
========

Use Spotify from the command line

Installation
------------

Add this line to your application's Gemfile:

```bash
$ gem install shellify
```

#### Setup

1. Create a Spotify application in the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
1. Get your Spotify OAUTH `access_token` and `refresh_token`. (Shelilfy currently doesn't currently implement a two way OAUTH flow, but Spotify has [sample apps](https://github.com/spotify/web-api-auth-examples) that you can use  to get your initial keys. Shellify will handle exchanging refresh tokens for access tokens after initial setup.)
1. Create two json files in `~/.config/shellify`
    `config.json`
    ```json
    {
      "client_id": "xxxxxxxxxxxxxxxx",
      "client_secret": "xxxxxxxxxxxxxxx"
    }
    ```

    `spotify_user.json`
    ```json
    {
      "id": "spotify_user_id",
      "token": "xxxxxxxxxxxxxxx",
      "refresh_token": "xxxxxxxxxxxxxxx"
    }
    ```

Commands
--------

```
$ shellify
  Now Playing:
  3 Libras - A Perfect Circle - 02:24/03:39 - ♥
```

See `shellify help` for a full list of commands.

RSpotify
--------

Shellify is basically a just a wrapper for [RSpotify](https://github.com/guilhermesad/rspotify) and wouldn't be possible (without significantly more effort) thanks to the work that's already been done over there.

License
-------

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

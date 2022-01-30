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

1. Create an application on the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
1. Add `http://localhost:8888/callback` to the Spotify Application's Redirect URIs
1. Run `shellify configure`
1. Run `shellify authenticate`

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

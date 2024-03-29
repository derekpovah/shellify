# frozen_string_literal: true

require 'commander'
require 'shellify/utils'

module Shellify
  class Cli
    include Commander::Methods
    include Shellify::Utils

    def initialize
      $VERBOSE = nil # Suppress warnings from RSpotify's rest-client implementation by default
      @config = Shellify::Config.new
      @user = Shellify::User.new(@config.config_dir)
    end

    def run
      program :name, 'Shellify'
      program :version, Shellify::VERSION
      program :description, 'Use Spotify from the command line'

      command :configure do |c|
        c.description = 'Set the Spotify client_id and client_secret'
        c.action do
          client_id = ask('Spotify Client ID: ')
          client_secret = ask('Spotify Client Secret: ') { |q| q.echo = '*' }
          @config.client_id = client_id
          @config.client_secret = client_secret
          @config.save!
        end
      end

      command :authenticate do |c|
        c.description = 'Authenticate with the Spotify API'
        c.action do
          spotify_username = ask('Your Spotify Username: ')
          puts
          puts 'Go to the link below to authorize Shellify.'
          puts generate_oauth_url
          oauth_credentials = Shellify::OauthCallbackHandler.run(@config)
          @user.id = spotify_username
          @user.token = oauth_credentials['access_token']
          @user.refresh_token = oauth_credentials['refresh_token']
          @user.save!
        end
      end

      command :devices do |c|
        c.description = 'List available playback devices'
        c.action do
          devices = @user.devices
          devices.each do |device|
            puts "  #{device.name}#{" - \e[1m𝅘𝅥𝅮\e[22m" if device.is_active}"
          end
        end
      end

      command :playing do |c|
        c.description = 'List information about the current song'
        c.action do
          return puts '  Nothing playing' unless @user.player.playing?

          print_currently_playing
        end
      end

      command :volume do |c|
        c.description = 'Set the volume of the current playback device'
        c.action do |args, _options|
          @user.player.volume(args[0])
        end
      end

      command :like do |c|
        c.description = 'Save the current song to your library'
        c.action do
          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          @user.save_tracks!([playing])
        end
      end

      command :unlike do |c|
        c.description = 'Remove the current song from your library'
        c.action do
          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          @user.remove_tracks!([playing])
        end
      end

      command :playlists do |c|
        c.description = 'List your playlists'
        c.action do
          @user.playlists.each do |playlist|
            puts "  #{playlist.name} - #{playlist.owner.display_name}#{' - Collaborative' if playlist.collaborative}"
          end
        end
      end

      command :add do |c|
        c.description = 'Add the current song or album to the provided playlist'
        c.option '-a', '--album'
        c.action do |args, options|
          return puts '  Nothing playing' unless @user.player.playing?

          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts '  Playlist not found' unless playlist

          exit_with_message(add_to_collaborative_playlist_message, 0) if playlist.owner.id != @user.id

          item = options.album ? playing.album.tracks : [playing]
          playlist.add_tracks!(item)
        end
      end

      command :queue do |c|
        c.description = 'List the next songs in the queue'
        c.action do
          items = @user.player.next_up
          exit_with_message('  Nothing in the queue', 0) if items.empty?
          items.each.with_index(1) do |item, i|
            case item.type
            when 'episode'
              puts "  #{i.to_s.rjust(items.size.to_s.size, ' ')} - #{item.name} - #{item.show.name}"
            when 'track'
              puts "  #{i.to_s.rjust(items.size.to_s.size, ' ')} - #{item.name} - "\
                   "#{item.artists.map(&:name).join(', ')}"
            end
          end
        end
      end

      command :remove do |c|
        c.description = 'Remove the currently playing song or album from the provided playlist'
        c.option '-a', '--album'
        c.action do |args, options|
          return puts '  Nothing playing' unless @user.player.playing?

          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts '  Playlist not found' unless playlist

          exit_with_message(add_to_collaborative_playlist_message, 0) if playlist.owner.id != @user.id

          item = options.album ? playing.album.tracks : [playing]
          playlist.remove_tracks!(item)
        end
      end

      command :play do |c|
        c.description = 'Play or Pause on the currently playing device'
        c.action do
          if @user.player.playing?
            @user.player.pause
          else
            @user.player.play
            print_currently_playing
          end
        rescue RestClient::NotFound
          @user.player.play(@user.devices.first.id)
        end
      end

      command :next do |c|
        c.description = 'Skip to the next song in the queue'
        c.action do
          @user.player.next
          print_currently_playing
        end
      end

      command :previous do |c|
        c.description = 'Skip the the previous song in the queue'
        c.action do
          @user.player.previous
          print_currently_playing
        end
      end

      command :restart do |c|
        c.description = 'Restart the currently playing song'
        c.action do
          @user.player.seek 0
          print_currently_playing
        end
      end

      command :seek do |c|
        c.description = 'Seek to the specified time in the current song'
        c.action do |args, _option|
          @user.player.seek(time_to_ms(args[0]))
          print_currently_playing
        end
      end

      default_command :playing
      alias_command :pause, :play
      alias_command :back, :previous
      alias_command :skip, :next

      run!
    end

    private

    def playing
      @user.player.currently_playing
    end

    def local_track_message
      "  Shellify can't perform this action for local tracks"
    end

    def add_to_collaborative_playlist_message
      "  Shellify can't perform this action for collaborative playlists you don't own"
    end

    def track_is_local?(track)
      track.uri.split(':')[1] == 'local'
    end

    def current_song
      puts "Now Playing - #{duration_to_s(@user.player.progress)}/#{duration_to_s(playing.duration_ms)}"\
           "#{' - ♥' if !track_is_local?(playing) && @user.saved_tracks?([playing]).first}"\
           "#{' - local' if track_is_local?(playing)}\n"\
           "  #{playing.name}\n"\
           "  #{playing.album.name}\n"\
           "  #{playing.artists.map(&:name).join(', ')}"
    end

    def print_currently_playing
      if playing.nil?
        puts "Now Playing - Podcast - #{duration_to_s(@user.player.progress)}"
      else
        current_song
      end
    end

    def exit_with_message(message, code = 1)
      puts message
      exit code
    end
  end
end

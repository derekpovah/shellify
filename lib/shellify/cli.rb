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
          client_id = ask("Spotify Client ID: ")
          client_secret = ask("Spotify Client Secret: ") { |q| q.echo = '*' }
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
          return puts "  Nothing playing" unless @user.player.playing?

          print_current_song
        end
      end

      command :volume do |c|
        c.description = 'Set the volume of the current playback device'
        c.action do |args, options|
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
            puts "  #{playlist.name} - #{playlist.owner.display_name}#{" - Collaborative" if playlist.collaborative}"
          end
        end
      end

      command :add do |c|
        c.description = 'Add the current song to the provided playlist'
        c.action do |args, options|
          return puts "  Nothing playing" unless @user.player.playing?

          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts "  Playlist not found" unless playlist
          exit_with_message(add_to_collaborative_playlist_message, 0) if playlist.owner.id != @user.id

          playlist.add_tracks!([playing])
        end
      end

      command :remove do |c|
        c.description = 'Remove the currently playing song from the provided playlist'
        c.action do |args, options|
          return puts "  Nothing playing" unless @user.player.playing?

          exit_with_message(local_track_message, 0) if track_is_local?(playing)
          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts "  Playlist not found" unless playlist
          exit_with_message(add_to_collaborative_playlist_message, 0) if playlist.owner.id != @user.id

          playlist.remove_tracks!([playing])
        end
      end

      command :play do |c|
        c.description = 'Play or Pause on the currently playing device'
        c.action do
          begin
            if @user.player.playing?
              @user.player.pause
            else
              @user.player.play
              print_current_song
            end
          rescue RestClient::NotFound
            @user.player.play(@user.devices.first.id)
          end
        end
      end

      command :next do |c|
        c.description = 'Skip to the next song in the queue'
        c.action do
          @user.player.next
          print_current_song
        end
      end

      command :previous do |c|
        c.description = 'Skip the the previous song in the queue'
        c.action do
          @user.player.previous
          print_current_song
        end
      end

      command :restart do |c|
        c.description = 'Restart the currently playing song'
        c.action do
          @user.player.seek 0
          print_current_song
        end
      end

      command :seek do |c|
        c.description = 'Seek to the specified time in the current song'
        c.action do |args, option|
          @user.player.seek(time_to_ms(args[0]))
          print_current_song
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
      " Shellify can't perform this action for collaborative playlists you don't own"
    end

    def track_is_local?(track)
      track.uri.split(':')[1] == 'local'
    end

    def print_current_song
      puts '  Now Playing:'
      puts "  #{playing.name} - #{playing.artists.first.name} - "\
           "#{duration_to_s(@user.player.progress)}/#{duration_to_s(playing.duration_ms)}"\
           "#{" - ♥" if !track_is_local?(playing) && @user.saved_tracks?([playing]).first}"\
           "#{" - local" if track_is_local?(playing)}"

    end

    def exit_with_message(message, code = 1)
      puts message
      exit code
    end
  end
end

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
          @user.save_tracks!([@user.player.currently_playing])
        end
      end

      command :unlike do |c|
        c.description = 'Remove the current song from your library'
        c.action do
          @user.remove_tracks!([@user.player.currently_playing])
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

          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts "  Playlist not found" unless playlist

          playlist.add_tracks!([@user.player.currently_playing])
        end
      end

      command :remove do |c|
        c.description = 'Remove the currently playing song from the provided playlist'
        c.action do |args, options|
          return puts "  Nothing playing" unless @user.player.playing?

          playlist = @user.playlists.find { |p| p.name == args[0] }
          return puts "  Playlist not found" unless playlist

          playlist.remove_tracks!([@user.player.currently_playing])
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

    def print_current_song
      playing = @user.player.currently_playing
      puts '  Now Playing:'
      puts "  #{playing.name} - #{playing.artists.first.name} - "\
           "#{duration_to_s(@user.player.progress)}/#{duration_to_s(playing.duration_ms)}"\
           "#{" - ♥" if @user.saved_tracks?([playing]).first}"
    end

    def exit_with_message(message, code = 1)
      puts message
      exit code
    end
  end
end

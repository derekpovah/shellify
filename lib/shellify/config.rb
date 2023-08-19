# frozen_string_literal: true

module Shellify
  class Config
    attr_accessor :client_id, :client_secret, :config_dir

    CONFIG_DIR = "#{ENV['HOME']}/.config/shellify"
    CONFIG_FILE = "#{CONFIG_DIR}/config.json"
    SPOTIFY_AUTHORIZATION_SCOPES = %w[
      user-read-playback-state
      user-modify-playback-state
      user-read-currently-playing
      user-library-modify
      user-library-read
      playlist-modify-private
      playlist-read-collaborative
      playlist-read-private
      playlist-modify-public
    ].join(' ')

    def initialize
      @config_dir = CONFIG_DIR
      @config_file = CONFIG_FILE
      load_config
      RSpotify.authenticate(@client_id, @client_secret) if configured?
    end

    def configured?
      !@client_id.nil? && !@client_secret.nil?
    end

    def save!
      File.open(CONFIG_FILE, 'w') do |file|
        file.write(JSON.pretty_generate({client_id: @client_id, client_secret: @client_secret}))
      end
    end

    private

    def load_config
      return unless File.exists?(CONFIG_FILE)

      JSON.parse(File.read(CONFIG_FILE)).each_pair { |k,v| instance_variable_set("@#{k}", v) }
    end
  end
end

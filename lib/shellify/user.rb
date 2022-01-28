# frozen_string_literal: true

module Shellify
  class User < RSpotify::User

    USER_FILE = '/spotify_user.json'

    def initialize(config_dir)
      @config_dir = config_dir
      create_user_file
      @spotify_user = load_persisted_user
      super({
        'credentials' => {
          'token' => @spotify_user.token,
          'refresh_token' => @spotify_user.refresh_token,
          'access_refresh_callback' => access_refresh_callback,
        },
        'id' => @spotify_user.id,
      })
    end

    private

    def load_persisted_user
      OpenStruct.new(JSON.parse(File.read(@config_dir + USER_FILE)))
    end

    def persist_user(access_token)
      @spotify_user.token = access_token

      File.open(@config_dir + USER_FILE, 'w') do |file|
        file.write(JSON.pretty_generate(@spotify_user.to_h))
      end
    end

    def access_refresh_callback
      Proc.new do |new_access_token, _token_lifetime|
        persist_user(new_access_token)
      end
    end

    def create_user_file
      return if File.exists?(@config_dir + USER_FILE)

      FileUtils.mkdir_p(CONFIG_DIR)
      FileUtils.touch(@config_dir + USER_FILE)
    end
  end
end

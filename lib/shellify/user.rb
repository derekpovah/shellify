# frozen_string_literal: true

module Shellify
  class User < RSpotify::User
    attr_accessor :token, :refresh_token, :id

    USER_FILE = '/spotify_user.json'

    def initialize(config_dir)
      @config_dir = config_dir
      @user_file_path = config_dir + USER_FILE
      create_user_file
      write_default_user
      load_persisted_user
      super({
        'credentials' => {
          'token' => @token,
          'refresh_token' => @refresh_token,
          'access_refresh_callback' => access_refresh_callback,
        },
        'id' => @id,
      })
    end

    def configured?
      !@token.empty? && !@refresh_token.empty? && !@id.empty?
    end

    def save!
      File.open(@user_file_path, 'w') do |file|
        file.write(JSON.pretty_generate({ id: @id, token: @token, refresh_token: @refresh_token }))
      end
    end

    private

    def load_persisted_user
      JSON.parse(File.read(@user_file_path)).each_pair { |k, v| instance_variable_set("@#{k}", v) }
    end

    def access_refresh_callback
      proc do |new_access_token, _token_lifetime|
        @token = new_access_token
        save!
      end
    end

    def create_user_file
      return if File.exists?(@user_file_path)

      FileUtils.mkdir_p(@config_dir)
      FileUtils.touch(@user_file_path)
    end

    def write_default_user
      return unless File.zero?(@user_file_path)

      File.open(@user_file_path, 'w') do |file|
        file.write(JSON.pretty_generate({ id: '', token: '', refresh_token: '' }))
      end
    end
  end
end

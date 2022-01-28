# frozen_string_literal: true

module Shellify
  class Config
    attr_reader :client_id, :client_secret, :config_dir

    CONFIG_DIR = ENV['HOME'] + '/.config/shellify'
    CONFIG_FILE = CONFIG_DIR + '/config.json'

    def initialize
      @config_dir = CONFIG_DIR
      @config_file = CONFIG_FILE
      create_config_file
      load_config
      RSpotify.authenticate(@client_id, @client_secret)
    end

    private

    def load_config
      JSON.parse(File.read(CONFIG_FILE)).each_pair { |k,v| instance_variable_set("@#{k}", v) }
    end

    def create_config_file
      return if File.exists?(CONFIG_FILE)

      FileUtils.mkdir_p(CONFIG_DIR)
      FileUtils.touch(CONFIG_FILE)
      write_default_config
    end

    def write_default_config
      File.open(CONFIG_FILE, 'w') do |file|
      file.write(JSON.pretty_generate({client_id: '', client_secret: ''}))
      end
    end
  end
end

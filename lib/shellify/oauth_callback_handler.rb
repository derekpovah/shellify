# frozen_string_literal: true

require 'socket'
require 'cgi'
require 'base64'

module Shellify
  class OauthCallbackHandler
    def self.run(...)
      new(...).run
    end

    def initialize(config)
      @config = config
    end

    def run
      @server = TCPServer.open(8888)
      @client = @server.accept

      path = @client.gets.split[1]
      params = CGI.parse(path.split('?').last).transform_values(&:first)
      body = 'Success! (You can close this now)'

      begin
        tokens = fetch_tokens(params['code'])
      rescue RestClient::Exception => e
        body = "Spotify didn't like that\n" + e.response
      end

      @client.puts headers(body.length)
      @client.puts body
      tokens
    ensure
      @client.close if @client
      @server.close
    end

    private

    def headers(content_length)
      [
        'HTTP/1.1 200 Ok',
        "date: #{Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")}",
        'server: ruby',
        "Content-Length: #{content_length}",
        '',
        '',
      ].join("\r\n")
    end

    def fetch_tokens(code)
      headers = {
        'Authorization': "Basic " + Base64.strict_encode64("#{@config.client_id}:#{@config.client_secret}"),
      }

      params = {
        client_id: @config.client_id,
        scope: Shellify::Config::SPOTIFY_AUTHORIZATION_SCOPES,
        redirect_uri: 'http://localhost:8888/callback',
        grant_type: 'authorization_code',
        code: code,
      }

      JSON.parse(RestClient.post("https://accounts.spotify.com/api/token", params, headers))
    end
  end
end

# frozen_string_literal: true

require 'time'
require 'uri'

module Shellify
  module Utils
    def duration_to_s(duration)
      secs, _millis = duration.divmod(1000)
      mins, secs = secs.divmod(60)
      hours, mins = mins.divmod(60)
      hours = nil if hours.zero?
      [hours, mins, secs].compact.map { |s| s.to_s.rjust(2, '0') }.join(':')
    end

    def time_to_ms(time)
      time.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b } * 1000
    end

    def generate_oauth_url
      url_params = {
        response_type: 'code',
        client_id: @config.client_id,
        scope: Shellify::Config::SPOTIFY_AUTHORIZATION_SCOPES,
        redirect_uri: 'http://localhost:8888/callback',
      }

      "https://accounts.spotify.com/authorize?#{URI.encode_www_form(url_params)}"
    end
  end
end

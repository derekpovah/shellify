# frozen_string_literal: true

module RSpotify
  class Player
    def next_up
      url = 'me/player/queue'
      response = User.oauth_get(@user.id, url)
      return response if RSpotify.raw_response

      response['queue'].map do |item|
        type_class = RSpotify.const_get(item['type'].capitalize)
        type_class.new item
      end
    end

    def currently_playing
      url = 'me/player/currently-playing'
      response = User.oauth_get(@user.id, url)
      return response if RSpotify.raw_response

      type_class = RSpotify.const_get(response['currently_playing_type'].capitalize)
      type_class.new response['item'] unless response['item'].nil?
    end
  end
end

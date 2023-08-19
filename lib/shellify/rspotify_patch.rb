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
  end
end

# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'rspotify'
require 'shellify/rspotify_patch'
require 'shellify/version'

module Shellify
  autoload :Cli,                  'shellify/cli'
  autoload :Config,               'shellify/config'
  autoload :User,                 'shellify/user'
  autoload :OauthCallbackHandler, 'shellify/oauth_callback_handler'
end

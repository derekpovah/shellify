# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'rspotify'
require 'shellify/version'

module Shellify
  autoload :Cli,     'shellify/cli'
  autoload :Config,  'shellify/config'
  autoload :User,    'shellify/user'
end

# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shellify/version'

Gem::Specification.new do |spec|
  spec.name = 'shellify'
  spec.version = Shellify::VERSION
  spec.authors = ['Derek Povah']
  spec.email = ['derek@derekpovah.com']

  spec.summary = 'Use Spotify from the command line'
  spec.homepage = 'https://github.com/derekpovah/shellify'
  spec.license = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['README.md', 'LICENSE.txt', 'lib/**/*', 'exe/**/*']
  spec.bindir = 'exe'
  spec.executables << 'shellify'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'commander', '~> 4.6.0'
  spec.add_dependency 'rspotify', '~> 2.11.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0.1'
end

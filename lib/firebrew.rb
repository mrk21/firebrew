require "firebrew/version"

module Firebrew
  class Error < StandardError; end
end

require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'
require 'firebrew/runner'

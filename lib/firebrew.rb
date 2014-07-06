require "firebrew/version"

module Firebrew
  class Error < StandardError; end
  class ProfilesIniNotFoundError < Error; end
  class ProfileNotFoundError < Error; end
  class ExtensionNotFoundError < Error; end
end

require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'
require 'firebrew/runner'
require 'firebrew/command_line'

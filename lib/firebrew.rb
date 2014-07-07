require "firebrew/version"

module Firebrew
  class Error < StandardError; end
  class ProfilesFileNotFoundError < Error; end
  class ProfileNotFoundError < Error; end
  class ExtensionsFileNotFoundError < Error; end
  class ExtensionNotFoundError < Error; end
end

require 'firebrew/entity'
require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'
require 'firebrew/runner'
require 'firebrew/command_line'

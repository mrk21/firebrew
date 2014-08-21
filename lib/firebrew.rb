require "firebrew/version"

module Firebrew
  class Error < StandardError; def status; 1 end end
  class ProfilesFileNotFoundError < Error; def status; 2 end end
  class ProfileNotFoundError < Error; def status; 3 end end
  class ExtensionNotFoundError < Error; def status; 4 end end
  class FirefoxCommandError < Error; def status; 5 end end
  class CommandLineError < Error; def status; 6 end end
  class OperationAlreadyCompletedError < Error; def status; 7 end end
end

require 'active_support/all'
require 'firebrew/entity'
require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'
require 'firebrew/firefox/command'
require 'firebrew/runner'
require 'firebrew/command_line'

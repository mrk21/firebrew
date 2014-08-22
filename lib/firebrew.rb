require "firebrew/version"
require 'rake/pathmap'

module Firebrew
  class Error < StandardError; def status; 1 end end
  class ProfilesFileNotFoundError < Error; end
  class ProfileNotFoundError < Error; end
  class ExtensionNotFoundError < Error; end
  class FirefoxCommandError < Error; end
  class CommandLineError < Error; end
  class OperationAlreadyCompletedError < Error; def status; 2 end end
end

Dir[__FILE__.pathmap('%X/*.rb')].each do |rb|
  require rb.pathmap('%-1d/%n')
end

require "firebrew/version"
require 'rake/pathmap'

module Firebrew
  class Error < StandardError; def status; 1 end end
  class ProfilesFileNotFoundError < Error; def status; 2 end end
  class ProfileNotFoundError < Error; def status; 3 end end
  class ExtensionNotFoundError < Error; def status; 4 end end
  class FirefoxCommandError < Error; def status; 5 end end
  class CommandLineError < Error; def status; 6 end end
  class OperationAlreadyCompletedError < Error; def status; 7 end end
end

Dir[__FILE__.pathmap('%X/*.rb')].each do |rb|
  require rb.pathmap('%-1d/%n')
end

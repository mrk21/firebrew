require 'shellwords'

module Firebrew::Firefox
  class Command
    class Executer
      def exec(command)
        [%x[#{command}], $?]
      end
    end
    
    def initialize(config={}, executer = Executer.new)
      @config = config
      @executer = executer
      begin
        result = @executer.exec('%{firefox} --version' % self.escaped_config)
        raise Firebrew::FirefoxCommandError unless result[0] =~ /Mozilla Firefox/
        raise Firebrew::FirefoxCommandError unless result[1] == 0
      rescue SystemCallError
        raise Firebrew::FirefoxCommandError
      end
    end
    
    def version
      return @version unless @version.nil?
      result = @executer.exec('%{firefox} --version' % self.escaped_config)[0]
      @version = result.match(/[0-9.]+/)[0]
    end
    
    protected
    
    def escaped_config
      result = @config.clone
      result[:firefox] = Shellwords.escape result[:firefox]
      result
    end
  end
end

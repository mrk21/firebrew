require 'shellwords'
require 'os'

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
        result = if OS.windows? then
          @executer.exec('"%{firefox}" --version' % @config)
        else
          @executer.exec('%{firefox} --version' % self.escaped_config)
        end
        raise Firebrew::FirefoxCommandError, 'Command is not Firefox: %{firefox}' % @config unless result[0] =~ /Mozilla Firefox/
        raise Firebrew::FirefoxCommandError, 'Command is not Firefox: %{firefox}' % @config unless result[1] == 0
      rescue SystemCallError
        raise Firebrew::FirefoxCommandError, 'Firefox command not found: %{firefox}' % @config
      end
    end
    
    def version
      return @version unless @version.nil?
      result = if OS.windows? then
        @executer.exec('"%{firefox}" --version' % @config)[0]
      else
        @executer.exec('%{firefox} --version' % self.escaped_config)[0]
      end
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

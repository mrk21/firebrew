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
        result = @executer.exec('%{firefox} --version' % @config)
        raise Firebrew::FirefoxCommandError unless result[0] =~ /Mozilla Firefox/
        raise Firebrew::FirefoxCommandError unless result[1] == 0
      rescue SystemCallError
        raise Firebrew::FirefoxCommandError
      end
    end
    
    def version
      return @version if @version.present?
      result = @executer.exec('%{firefox} --version' % @config)[0]
      @version = result.match(/[0-9.]+/)[0]
    end
    
    def update_profile
      @executer.exec('%{firefox} -P %{profile} -silent' % @config)[0]
    end
  end
end

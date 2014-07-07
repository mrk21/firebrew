module Firebrew::Firefox
  class Command
    def initialize(config={})
      @config = config
    end
    
    def version
      return @version if @version.present?
      command = '%{firefox} --version' % @config
      result = %x[#{command}]
      @version = result.match(/[0-9.]+/)[0]
    end
    
    def update_profile
      system '%{firefox} -P %{profile} -silent' % @config
    end
  end
end

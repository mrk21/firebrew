module Firebrew::Firefox
  class Command
    def initialize(config={})
      @config = config
    end
    
    def update_profile
      system '%{firefox} -P %{profile} -silent' % @config
    end
  end
end

require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'

module Firebrew
  class Runner
    def initialize(config={})
      @profile_manager = Firefox::Profile::Manager.new(base_dir: config[:base_dir])
    end
    
    def select_profile(name)
      @profile = @profile_manager.find(name)
    end
    
    def install(name)
      result = AmoApi::Search.fetch(term: name, max: 1).first
      @profile.extensions.install(result.extension)
    end
  end
end

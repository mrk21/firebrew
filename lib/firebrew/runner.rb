require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'

module Firebrew
  class Runner
    attr_accessor :config, :profile
    
    def self.default_config(platform = RUBY_PLATFORM)
      result = {
        base_dir: ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'],
        firefox: ENV['FIREBREW_FIREFOX'],
        profile: ENV['FIREBREW_FIREFOX_PROFILE'] || 'default',
      }
      
      case platform
      when /darwin/ then
        result[:base_dir] ||= '~/Library/Application Support/Firefox'
        result[:firefox] ||= '/Applications/Firefox.app/Contents/MacOS/firefox-bin'
        
      when /linux/ then
        result[:base_dir] ||= '~/.mozilla/firefox'
        result[:firefox] ||= '/usr/bin/firefox'
        
      when /mswin(?!ce)|mingw|cygwin|bccwin/ then
        result[:base_dir] ||= '~/AppData/Roming/Mozilla/Firefox'
        result[:firefox] ||= 'C:/Program Files (x86)/Mozilla Firefox/firefox.exe'
      end
      
      result
    end
    
    def initialize(config={})
      self.config = self.class.default_config.merge(config)
      
      @profile_manager = Firefox::Profile::Manager.new(
        base_dir: self.config[:base_dir],
        data_file: self.config[:data_file]
      )
      @firefox = Firefox::Command.new(self.config)
      
      self.select_profile
    end
    
    def select_profile(name = nil)
      self.profile = @profile_manager.find!(name || self.config[:profile])
    end
    
    def install(params={})
      result = self.fetch_api(term: params[:term], max: 1).first
      self.profile.extensions.install(result.extension)
    end
    
    def uninstall(params={})
      self.profile.extensions.find!(params[:term]).delete
    end
    
    def info(params={})
      self.fetch_api(term: params[:term], max: 1).first
    end
    
    def list(params={})
      self.profile.extensions.all
    end
    
    def search(params={})
      self.fetch_api(term: params[:term])
    end
    
    protected
    
    def fetch_api(params={})
      params.merge!(version: @firefox.version)
      AmoApi::Search.fetch!(params)
    end
  end
end

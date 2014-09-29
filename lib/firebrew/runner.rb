require 'firebrew/amo_api/search'
require 'firebrew/firefox/profile'
require 'firebrew/firefox/extension'
require 'firebrew/firefox/command'

module Firebrew
  class Runner
    attr_accessor :config, :profile
    
    def self.default_config
      result = {
        base_dir: ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'],
        firefox: ENV['FIREBREW_FIREFOX'],
        profile: ENV['FIREBREW_FIREFOX_PROFILE'] || 'default',
      }
      
      if OS.mac? then
        result[:base_dir] ||= '~/Library/Application Support/Firefox'
        result[:firefox] ||= '/Applications/Firefox.app/Contents/MacOS/firefox-bin'
        result[:os] = 'darwin'
        
      elsif OS.linux? then
        result[:base_dir] ||= '~/.mozilla/firefox'
        result[:firefox] ||= '/usr/bin/firefox'
        result[:os] = 'linux'
        
      elsif OS.windows? then
        appdata = ENV['APPDATA'].to_s.gsub('\\','/')
        programfiles = (ENV['PROGRAMFILES(X86)'] || ENV['PROGRAMFILES']).to_s.gsub('\\','/')
        result[:base_dir] ||= File.join(appdata, 'Mozilla/Firefox')
        result[:firefox] ||= File.join(programfiles, 'Mozilla Firefox/firefox.exe')
        result[:os] = 'winnt'
      end
      
      result
    end
    
    def initialize(config={}, is_displaying_progress = false)
      self.config = self.class.default_config.merge(config)
      @is_displaying_progress = is_displaying_progress
      
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
      extension = self.profile.extensions.find(params[:term])
      raise Firebrew::OperationAlreadyCompletedError, "Already installed: #{params[:term]}" unless extension.nil?
      result = self.fetch_api(term: params[:term], max: 1).first
      self.profile.extensions.install(result, @is_displaying_progress)
    end
    
    def uninstall(params={})
      begin
        self.profile.extensions.find!(params[:term]).delete
      rescue Firebrew::ExtensionNotFoundError
        raise Firebrew::OperationAlreadyCompletedError, "Already uninstalled: #{params[:term]}"
      end
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
      params.merge!(version: @firefox.version, os: self.config[:os])
      AmoApi::Search.fetch!(params)
    end
  end
end

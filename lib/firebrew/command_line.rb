require 'optparse'

module Firebrew
  class CommandLine
    attr_accessor :config
    
    def self.default_global_options(platform = RUBY_PLATFORM)
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
    
    def initialize(args=[])
      opt = OptionParser.new
      opt.version = Firebrew::VERSION
      
      self.config = {
        command: '',
        options: {},
        global_options: self.class.default_global_options
      }
      
      self.register_global_options(opt)
      opt.order!(args)
      
      case args.shift
      when 'install' then
        self.register_install_options(opt)
        opt.permute!(args)
        
        self.config[:command] = :install
        self.config[:options][:term] = args[0]
        
      when 'uninstall' then
        opt.permute!(args)
        self.config[:command] = :uninstall
        self.config[:options][:term] = args[0]
        
      when 'search' then
        self.register_search_options(opt)
        opt.permute!(args)
        
        self.config[:command] = :search
        self.config[:options][:term] = args[0]
        self.config[:options][:is_display] = true
        
      when 'list' then
        opt.permute!(args)
        self.config[:command] = :list
        
      when nil then
        opt.permute(['--help'])
      end
    end
    
    def execute
      runner = Runner.new(self.config[:global_options])
      runner.select_profile(self.config[:global_options][:profile])
      runner.send(self.config[:command], self.config[:options])
    end
    
    protected
    
    def register_global_options(opt)
      opt.on('-d path','--base-dir=path','Firefox profiles.ini directory') do |v|
        self.config[:global_options][:base_dir] = v
      end
      
      opt.on('-p name','--profile=name','Firefox profile name') do |v|
        self.config[:global_options][:profile] = v
      end
      
      opt.on('-f path','--firefox=path','Firefox command path') do |v|
        self.config[:global_options][:firefox] = v
      end
    end
    
    def register_install_options(opt)
      opt.on('-t value','--type=value','Extension type') do |v|
        self.config[:options][:type] = v
      end
      
      opt.on('-v value','--version=value','Extension version') do |v|
        self.config[:options][:version] = v
      end
    end
    
    def register_search_options(opt)
      opt.on('-t value','--type=value','Extension type') do |v|
        self.config[:options][:type] = v
      end
      
      opt.on('-v value','--version=value','Extension version') do |v|
        self.config[:options][:version] = v
      end
    end
  end
end

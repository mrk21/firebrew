require 'optparse'

module Firebrew
  class CommandLine
    attr_accessor :config
    
    def initialize(args=[])
      opt = OptionParser.new
      opt.version = Firebrew::VERSION
      
      self.config = {
        command: '',
        options: {},
        global_options: self.class.default_global_options
      }
      
      opt.on('-d path','--base-dir=path') do |v|
        self.config[:global_options][:base_dir] = v
      end
      
      opt.on('-p name','--profile=name') do |v|
        self.config[:global_options][:profile] = v
      end
      
      opt.on('-f path','--firefox=path') do |v|
        self.config[:global_options][:firefox] = v
      end
      
      opt.order!(args)
      
      case args.shift
      when 'install' then
        self.config[:command] = :install
        
        opt.on('-t value','--type=value') do |v|
          self.config[:options][:type] = v
        end
        
        opt.on('-v value','--version=value') do |v|
          self.config[:options][:version] = v
        end
        
        opt.permute!(args)
        
        self.config[:options][:package] = args[0]
        
      when nil then
        opt.permute(['--help'])
      end
    end
    
    def execute
      runner = Runner.new(self.config[:global_options])
      runner.select_profile(self.config[:global_options][:profile])
      runner.send(self.config[:command], self.config[:options])
    end
    
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
      end
      
      result
    end
  end
end

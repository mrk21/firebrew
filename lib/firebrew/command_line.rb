require 'optparse'

module Firebrew
  class CommandLine
    attr_accessor :arguments
    
    def initialize(args=[])
      opt = OptionParser.new
      opt.version = Firebrew::VERSION
      
      self.arguments = {
        command: nil,
        params: {},
        config: {}
      }
      
      self.register_global_options(opt)
      opt.order!(args)
      
      case args.shift
      when 'install' then
        self.register_install_options(opt)
        opt.permute!(args)
        
        self.arguments[:command] = :install
        self.arguments[:params][:term] = args[0]
        
      when 'uninstall' then
        opt.permute!(args)
        self.arguments[:command] = :uninstall
        self.arguments[:params][:term] = args[0]
        
      when 'info' then
        self.register_info_options(opt)
        opt.permute!(args)
        
        self.arguments[:command] = :info
        self.arguments[:params][:term] = args[0]
        
      when 'search' then
        self.register_search_options(opt)
        opt.permute!(args)
        
        self.arguments[:command] = :search
        self.arguments[:params][:term] = args[0]
        
      when 'list' then
        opt.permute!(args)
        self.arguments[:command] = :list
        
      when nil then
        opt.permute(['--help'])
      end
    end
    
    def execute
      runner = Runner.new(self.arguments[:config])
      
      case self.arguments[:command]
      when :search, :list then
        results = runner.send(self.arguments[:command], self.arguments[:params])
        results.each do |result|
          puts result.name
        end
        
      when :info then
        result = runner.send(self.arguments[:command], self.arguments[:params])
        puts result.to_xml
        
      else
        runner.send(self.arguments[:command], self.arguments[:params])
      end
    end
    
    protected
    
    def register_global_options(opt)
      opt.on('-d path','--base-dir=path','Firefox profiles.ini directory') do |v|
        self.arguments[:config][:base_dir] = v
      end
      
      opt.on('-p name','--profile=name','Firefox profile name') do |v|
        self.arguments[:config][:profile] = v
      end
      
      opt.on('-f path','--firefox=path','Firefox command path') do |v|
        self.arguments[:config][:firefox] = v
      end
    end
    
    def register_install_options(opt)
      opt.on('-t value','--type=value','Extension type') do |v|
        self.arguments[:params][:type] = v
      end
      
      opt.on('-v value','--version=value','Extension version') do |v|
        self.arguments[:params][:version] = v
      end
    end
    
    def register_info_options(opt)
      opt.on('-t value','--type=value','Extension type') do |v|
        self.arguments[:params][:type] = v
      end
      
      opt.on('-v value','--version=value','Extension version') do |v|
        self.arguments[:params][:version] = v
      end
    end
    
    def register_search_options(opt)
      opt.on('-t value','--type=value','Extension type') do |v|
        self.arguments[:params][:type] = v
      end
      
      opt.on('-v value','--version=value','Extension version') do |v|
        self.arguments[:params][:version] = v
      end
    end
  end
end

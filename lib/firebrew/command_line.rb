require 'optparse'
require 'firebrew/runner'

module Firebrew
  class CommandLine
    attr_accessor :arguments
    
    def self.execute
      begin
        if block_given? then
          yield
        else
          self.new(ARGV).execute
        end
      rescue Firebrew::Error => e
        $stderr.puts e.message
        exit e.status
      rescue SystemExit => e
        exit 1
      rescue Exception => e
        $stderr.puts e.inspect
        $stderr.puts e.backtrace
        exit 255
      else
        exit 0
      end
    end
    
    def initialize(args=[])
      opt = OptionParser.new
      opt.version = Firebrew::VERSION
      opt.banner = <<-USAGE.split(/\n/).map{|v| v.gsub(/^(  ){4}/,'')}.join("\n")
        Usage: firebrew [--help] [--version]
               [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
               <command> [<args>]
        
        commands:
            install:
                firebrew install <extension-name>
            
            uninstall:
                firebrew uninstall <extension-name>
            
            info:
                firebrew info <extension-name>
            
            search:
                firebrew search <term>
            
            list:
                firebrew list
        
        options:
      USAGE
      
      self.arguments = {
        command: nil,
        params: {},
        config: {}
      }
      
      self.register_global_options(opt)
      self.class.opt_operation(opt, :order!, args)
      
      case args.shift
      when 'install' then
        self.class.opt_operation(opt, :permute!, args)
        self.arguments[:command] = :install
        self.arguments[:params][:term] = args[0]
        
      when 'uninstall' then
        self.class.opt_operation(opt, :permute!, args)
        self.arguments[:command] = :uninstall
        self.arguments[:params][:term] = args[0]
        
      when 'info' then
        self.class.opt_operation(opt, :permute!, args)
        self.arguments[:command] = :info
        self.arguments[:params][:term] = args[0]
        
      when 'search' then
        self.class.opt_operation(opt, :permute!, args)
        self.arguments[:command] = :search
        self.arguments[:params][:term] = args[0]
        
      when 'list' then
        self.class.opt_operation(opt, :permute!, args)
        self.arguments[:command] = :list
        
      when nil then
        self.class.opt_operation(opt, :permute, ['--help'])
      
      else
        raise Firebrew::CommandLineError
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
        puts result.data
      else
        runner.send(self.arguments[:command], self.arguments[:params])
      end
    end
    
    protected
    
    def self.opt_operation(opt, operation, args)
      begin
        opt.send(operation, args)
      rescue OptionParser::InvalidOption
        raise Firebrew::CommandLineError
      end
    end
    
    def register_global_options(opt)
      opt.on('-d <path>','--base-dir=<path>','Firefox profiles.ini directory') do |v|
        self.arguments[:config][:base_dir] = v
      end
      
      opt.on('-p <name>','--profile=<name>','Firefox profile name') do |v|
        self.arguments[:config][:profile] = v
      end
      
      opt.on('-f <path>','--firefox=<path>','Firefox command path') do |v|
        self.arguments[:config][:firefox] = v
      end
    end
  end
end

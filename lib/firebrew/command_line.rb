require 'optparse'
require 'firebrew/runner'

module Firebrew
  class CommandLine
    attr_reader :arguments
    
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
        exit 1
      else
        exit 0
      end
    end
    
    def initialize(args=[])
      @arguments = {
        command: nil,
        params: {},
        config: {}
      }
      parser = self.option_parser
      parser.order!(args)
      command = args.shift.to_s.intern
      
      case command
      when :install, :uninstall, :info, :search then
        parser.permute!(args)
        self.arguments[:command] = command
        self.arguments[:params][:term] = args[0]
        
      when :list then
        parser.permute!(args)
        self.arguments[:command] = command
        
      when :'' then
        parser.permute(['--help'])
        
      else
        raise Firebrew::CommandLineError, "Invalid command: #{command}"
      end
      
    rescue OptionParser::ParseError => e
      m = e.message
      m[0] = m[0].upcase
      raise Firebrew::CommandLineError, m
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
    
    def option_parser
      parser = OptionParser.new
      parser.version = Firebrew::VERSION
      parser.banner = <<-USAGE.split(/\n/).map{|v| v.gsub(/^(  ){4}/,'')}.join("\n")
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
      USAGE
      
      parser.separator ''
      parser.separator 'options:'
      begin
        parser.on('-d <path>','--base-dir=<path>','Firefox profiles.ini directory') do |v|
          self.arguments[:config][:base_dir] = v
        end
        
        parser.on('-p <name>','--profile=<name>','Firefox profile name') do |v|
          self.arguments[:config][:profile] = v
        end
        
        parser.on('-f <path>','--firefox=<path>','Firefox command path') do |v|
          self.arguments[:config][:firefox] = v
        end
      end
      
      parser
    end
  end
end

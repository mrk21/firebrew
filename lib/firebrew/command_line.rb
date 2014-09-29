require 'optparse'
require 'erb'
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
        exit 0
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
      global_parser = self.option_parser do |parser|
        parser.banner = self.desc(<<-DESC)
          Usage: firebrew [--help] [--version]
                 [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
                 <command> [<args>]
        DESC
        
        parser.separator ''
        parser.separator 'commands:'
        begin
          pos = 11
          
          self.summary(parser, :install, <<-DESC, pos)
            Install the Firefox extension
          DESC
          
          self.summary(parser, :uninstall, <<-DESC, pos)
            Uninstall the Firefox extension
          DESC
          
          self.summary(parser, :info, <<-DESC, pos)
            Show detail information of the Firefox extension
          DESC
          
          self.summary(parser, :search, <<-DESC, pos)
            Search Firefox extensions
          DESC
          
          self.summary(parser, :list, <<-DESC, pos)
            Enumerate the installed Firefox extensions
          DESC
          
          self.summary(parser, :profile, <<-DESC, pos)
            Show the profile information
          DESC
        end
      end
      
      global_parser.order!(args)
      command = args.shift.to_s.intern
      
      case command
      when :install, :uninstall, :info then
        subcommand_parser = self.option_parser do |parser|
          parser.banner = self.desc(<<-DESC)
            Usage: firebrew [--help] [--version]
                   [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
                   #{command} <extension-name>
          DESC
        end
        
        subcommand_parser.permute!(args)
        self.arguments[:command] = command
        self.arguments[:params][:term] = args[0]
        
      when :search then
        subcommand_parser = self.option_parser do |parser|
          parser.banner = self.desc(<<-DESC)
            Usage: firebrew [--help] [--version]
                   [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
                   #{command} <term>
          DESC
        end
        
        subcommand_parser.permute!(args)
        self.arguments[:command] = command
        self.arguments[:params][:term] = args[0]
        
      when :list then
        subcommand_parser = self.option_parser do |parser|
          parser.banner = self.desc(<<-DESC)
            Usage: firebrew [--help] [--version]
                   [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
                   #{command}
          DESC
        end
        
        subcommand_parser.permute!(args)
        self.arguments[:command] = command
        
      when :profile then
        subcommand_parser = self.option_parser do |parser|
          parser.summary_width = 30
          parser.banner = self.desc(<<-DESC)
            Usage: firebrew [--help] [--version]
                   [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
                   #{command} [--attribute=<attr-name>]
          DESC
          
          parser.separator ''
          parser.separator 'options:'
          begin
            chooses = %r[#{Firebrew::Firefox::Profile.attributes.join('|')}]
            parser.on('-a <attr-name>','--attribute=<attr-name>', chooses, self.desc(<<-DESC)) do |v|
              The name of the attribute which want to display
            DESC
              self.arguments[:params][:attribute] = v
            end
          end
        end
        
        subcommand_parser.permute!(args)
        self.arguments[:command] = command
        
      when :'' then
        global_parser.permute(['--help'])
        
      else
        raise Firebrew::CommandLineError, "Invalid command: #{command}"
      end
      
    rescue OptionParser::ParseError => e
      m = e.message
      m[0] = m[0].upcase
      raise Firebrew::CommandLineError, m
    end
    
    def execute
      runner = Runner.new(self.arguments[:config], true)
      
      case self.arguments[:command]
      when :search, :list then
        results = runner.send(self.arguments[:command], self.arguments[:params])
        results.each do |result|
          puts result.name
        end
        
      when :info then
        result = runner.send(self.arguments[:command], self.arguments[:params])
        puts result.data
        
      when :profile then
        r = runner.profile
        attr = self.arguments[:params][:attribute]
        if attr.nil? then
          attrs = r.class.attributes
          puts ERB.new(self.desc(<<-XML),nil,'-').result(binding)
            <profile>
            <% attrs.each do |attr| -%>
              <<%= attr %>><%= r.send(attr) %></<%= attr %>>
            <% end -%>
            </profile>
          XML
        else
          puts r.send(attr)
        end
        
      else
        runner.send(self.arguments[:command], self.arguments[:params])
      end
    end
    
    protected
    
    def desc(str)
      lines = str.split(/\n/)
      indent = lines.map{|v| v.match(/^ +/).to_a[0].to_s.length}.min
      lines.map{|v| v[indent..-1].rstrip}.join("\n")
    end
    
    def summary(parser, name, description, pos)
      result = ' '*100
      result[0] = name.to_s
      result[pos+1] = self.desc(description)
      result = parser.summary_indent + result.rstrip
      parser.separator result
    end
    
    def option_parser
      parser = OptionParser.new
      parser.version = Firebrew::VERSION
      parser.summary_indent = ' '*3
      parser.summary_width = 25
      
      yield parser
      
      parser.separator ''
      parser.separator 'global options:'
      begin
        parser.on('-d <path>','--base-dir=<path>', String, self.desc(<<-DESC)) do |v|
          Firefox profiles.ini directory
        DESC
          self.arguments[:config][:base_dir] = v
        end
        
        parser.on('-p <name>','--profile=<name>', String, self.desc(<<-DESC)) do |v|
          Firefox profile name
        DESC
          self.arguments[:config][:profile] = v
        end
        
        parser.on('-f <path>','--firefox=<path>', String, self.desc(<<-DESC)) do |v|
          Firefox command path
        DESC
          self.arguments[:config][:firefox] = v
        end
      end
      
      parser.separator ''
      begin
        parser.on('-h', '--help', self.desc(<<-DESC)) do
          Show this message
        DESC
          puts parser.help
          exit
        end
        
        parser.on('-v', '--version', self.desc(<<-DESC)) do
          Show version
        DESC
          puts parser.ver
          exit
        end
      end
      
      parser.separator ''
      parser.separator 'return value:'
      begin
        pos = 3
        
        self.summary(parser, '0', <<-DESC, pos)
          Success
        DESC
        
        self.summary(parser, '1', <<-DESC, pos)
          Error
        DESC
        
        self.summary(parser, '2', <<-DESC, pos)
          No operation
        DESC
      end
      
      return parser
    end
  end
end

require 'uri'
require 'net/http'
require 'ruby-progressbar'

module Firebrew
  class Downloader
    def self.normalize_uri(uri)
      begin
        uri = URI.parse(uri)
      rescue URI::InvalidURIError
        uri = URI.parse(URI.encode uri)
      end
      
      uri.normalize!
      
      case uri.scheme
      when 'http','https','file' then
        # do nothing
      when nil then
        uri.scheme = 'file'
        path = File.expand_path(uri.path)
        path = "/#{path}" if path =~ /^[a-zA-Z]:/
        uri.path = path
      when /^[a-zA-Z]$/ then
        uri.path = "/#{uri.scheme.upcase}:#{uri.path}"
        uri.scheme = 'file'
      else
        raise Firebrew::NetworkError, "Don't support the scheme: #{uri.scheme}"
      end
      
      uri
    end
    
    def initialize(uri, out, progress_options={})
      @uri = self.class.normalize_uri(uri)
      @out = out
      @progress_options = progress_options
    end
    
    def exec
      case @uri.scheme
      when 'http','https' then
        @size = loop do
          response = self.http_connection do |http, path|
            http.head(path)
          end
          if response.code.to_i == 302 then
            @uri = self.class.normalize_uri(response['Location'])
            next
          end
          break response['Content-Length'].to_i
        end
        
        progress_bar = self.create_progress_bar
        
        self.http_connection do |http, path|
          http.get(path) do |chunk|
            progress_bar.progress += chunk.size
            @out.write chunk
          end
        end
        
      when 'file' then
        @size = self.file_connection do |file|
          file.size
        end
        
        progress_bar = self.create_progress_bar
        
        self.file_connection do |file|
          loop do
            chunk = file.read(1000)
            break if chunk.nil?
            progress_bar.progress += chunk.size
            @out.write chunk
          end
        end
      end
    end
    
    protected
    
    def http_connection(&block)
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        block[http, @uri.request_uri]
      end
    end
    
    def file_connection(&block)
      path = @uri.path.gsub(%r{/([a-zA-Z]:)},'\1')
      open(URI.decode(path), &block)
    end
    
    def create_progress_bar
      options = {
        format: "%e |%B| [%j%%]",
        progress_mark: '=',
        remainder_mark: '･',
      }
      options.merge! @progress_options
      options.merge! total: @size
      options[:output] = File.open(File::NULL,'w') unless options[:output]
      ProgressBar.create(options)
    end
  end
end

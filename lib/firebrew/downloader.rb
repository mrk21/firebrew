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
      
      uri.path = '/' if uri.path.empty?
      
      case uri.scheme
      when 'http','https','file' then
        # do nothing
      when nil then
        uri.scheme = 'file'
        if uri.path[0] != '/' then
          uri.path = File.expand_path(uri.path)
        end
      else
        raise Firebrew::NetworkError, "Don't support the scheme: #{uri.scheme}"
      end
      
      uri
    end
    
    attr_reader :uri, :save_to, :size, :received
    
    def initialize(uri, save_to, progress_bar_options={})
      @uri = self.class.normalize_uri(uri)
      @save_to = File.expand_path(save_to)
      @progress_bar_options = progress_bar_options
      
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
          break response['content-length'].to_i
        end
        
        @exec_block = lambda do
          progress_bar = self.create_progress_bar
          
          self.http_connection do |http, path|
            open(@save_to, 'w') do |w|
              http.get(path) do |chunk|
                @received += chunk.size
                progress_bar.progress = @received
                w.write chunk
              end
            end
          end
        end
        
      when 'file' then
        @size = self.file_connection do |file|
          file.size
        end
        
        @exec_block = lambda do
          progress_bar = self.create_progress_bar
          
          self.file_connection do |file|
            open(@save_to, 'wb') do |w|
              loop do
                chunk = file.read(1000)
                break if chunk.nil?
                @received += chunk.size
                progress_bar.progress = @received
                w.write chunk
              end
            end
          end
        end
      end
    end
    
    def exec
      @received = 0
      Thread.new &@exec_block
    end
    
    def completed?
      @size == @received
    end
    
    protected
    
    def http_connection(&block)
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        path = @uri.path
        path += "?#{@uri.query}" unless @uri.query.nil?
        block[http, path]
      end
    end
    
    def file_connection(&block)
      open(URI.decode(@uri.path, 'rb'), &block)
    end
    
    def create_progress_bar
      options = {title: 'Download'}
      options.merge! @progress_bar_options
      options.merge! total: @size
      options[:output] = File.open(File::NULL,'w') unless options[:output]
      ProgressBar.create(options)
    end
  end
end

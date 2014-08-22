require 'uri'
require 'rexml/document'
require 'faraday'
require 'firebrew/firefox/basic_extension'

module Firebrew::AmoApi
  class Search < Firebrew::Firefox::BasicExtension
    def self.connection=(val)
      @connection = val
    end
    
    def self.connection
      @connection ||= Faraday.new(url: 'https://services.addons.mozilla.org')
    end
    
    def self.path(params={})
      path_source = '/ja/firefox/api/%{api_version}/search/%{term}/%{type}/%{max}/%{os}/%{version}'
      default_params = {
        api_version: 1.5,
        type: 'all',
        max: 30,
        os: 'all',
        version: '',
      }
      URI.encode(path_source % default_params.merge(params))
    end
    
    def self.fetch(params={})
      response = self.connection.get(self.path params)
      dom = REXML::Document.new response.body
      addons = REXML::XPath.match(dom, '/searchresults/addon')
      addons.map{|v| Search.new v}
    end
    
    def self.fetch!(params={})
      results = self.fetch(params)
      raise Firebrew::ExtensionNotFoundError, 'Extension not found!' if results.empty?
      results
    end
    
    attr_reader :data
    
    def initialize(data)
      @data = data
      
      val = lambda do |name|
        REXML::XPath.match(self.data, "#{name}/text()").first.value.strip
      end
      
      super(
        name: val[:name],
        guid: val[:guid],
        uri: val[:install],
        version: val[:version]
      )
    end
  end
end

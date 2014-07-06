require 'active_resource'
require 'uri'
require 'firebrew/firefox/basic_extension'

module Firebrew::AmoApi
  class Search < ActiveResource::Base
    class Format
      include ActiveResource::Formats::XmlFormat
      
      def decode(xml)
        results = super(xml)['addon'] || []
        results.instance_of?(Array) ? results : [results]
      end
    end
    
    self.site = 'https://services.addons.mozilla.org'
    self.format = Format.new
    
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
      self.find(:all, from: self.path(params)).to_a
    end
    
    def self.fetch!(params={})
      results = self.fetch(params)
      raise Firebrew::ExtensionNotFoundError if results.empty?
      results
    end
    
    def extension
      Firebrew::Firefox::BasicExtension.new(
        name: self.name,
        guid: self.guid,
        uri: self.install,
        version: self.version
      )
    end
  end
end

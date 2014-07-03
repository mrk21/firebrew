require 'active_resource'
require 'uri'

module Firebrew::AmoApi
  class Search < ActiveResource::Base
    class Format
      include ActiveResource::Formats::XmlFormat
      
      def decode(xml)
        super(xml)['addon']
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
      self.find(:all, from: self.path(params))
    end
  end
end

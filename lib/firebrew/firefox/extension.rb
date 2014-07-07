require 'fileutils'
require 'open-uri'
require 'json'
require 'firebrew/firefox/basic_extension'

module Firebrew::Firefox
  class Extension < BasicExtension
    class Manager
      attr_reader :profile
      
      def initialize(params={})
        @profile = params[:profile]
      end
      
      def all
        json = JSON.load(File.read(self.data_path))
        
        profile_extensions = json['addons'].find_all do |extension|
          extension['location'] == 'app-profile'
        end
        
        profile_extensions.map do |extension|
          Extension.new(
            name: extension['defaultLocale']['name'],
            guid: extension['id'],
            version: extension['version'],
            uri: '%s.xpi' % File.join(self.profile.path, 'extensions', extension['id'])
          )
        end
      end
      
      def find(name)
        self.all.find{|ext| ext.name == name }
      end
      
      def find!(name)
        result = self.find(name)
        raise Firebrew::ExtensionNotFoundError if result.nil?
        result
      end
      
      def install(extension)
        dir = File.join(self.profile.path, 'extensions')
        FileUtils.mkdir_p dir
        install_path = '%s.xpi' % File.join(dir, extension.guid)
        
        open(extension.uri, 'rb') do |i|
          open(install_path, 'wb') do |o|
            o.write i.read
          end
        end
      end
      
      protected
      
      def data_path
        path = File.join(self.profile.path, 'extensions.json')
        raise Firebrew::ExtensionsFileNotFoundError unless File.exists? path
        path
      end
    end
    
    def delete
      FileUtils.rm_f self.uri
    end
  end
end

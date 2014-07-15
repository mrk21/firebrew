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
        profile_extensions = self.fetch['addons'].find_all do |extension|
          extension['location'] == 'app-profile'
        end
        
        profile_extensions.map do |extension|
          Extension.new({
            name: extension['defaultLocale']['name'],
            guid: extension['id'],
            version: extension['version'],
            uri: '%s.xpi' % File.join(self.profile.path, 'extensions', extension['id'])
          }, self)
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
        
        self.add(extension)
        self.push
      end
      
      def uninstall(extension)
        FileUtils.rm_f extension.uri
        self.remove(extension)
        self.push
      end
      
      protected
      
      def data_path
        path = File.join(self.profile.path, 'extensions.json')
        unless File.exists?(path) then
          File.write(path, %({"schemaVersion": 16, "addons": []}))
        end
        path
      end
      
      def fetch
        return @data if @data.present?
        @data = JSON.load(File.read(self.data_path))
      end
      
      def push
        json = JSON::pretty_generate(self.fetch, allow_nan: true, max_nesting: false)
        File.write(self.data_path, json)
      end
      
      def add(extension)
        self.fetch['addons'].push(
          'id'=> extension.guid,
          'location'=> 'app-profile',
          'version'=> extension.version,
          'defaultLocale'=> {
            'name'=> extension.name
          }
        )
      end
      
      def remove(extension)
        self.fetch['addons'].delete_if{|v| v['id'] == extension.guid}
      end
    end
    
    def initialize(attributes, manager)
      super(attributes)
      @manager = manager
    end
    
    def delete
      @manager.uninstall(self)
    end
  end
end

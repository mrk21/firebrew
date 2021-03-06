require 'fileutils'
require 'open-uri'
require 'json'
require 'rexml/document'
require 'rake/pathmap'
require 'zip'
require 'firebrew/firefox/basic_extension'
require 'firebrew/downloader'

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
            uri: extension['descriptor'],
          }, self)
        end
      end
      
      def find(name)
        self.all.find{|ext| ext.name == name }
      end
      
      def find!(name)
        result = self.find(name)
        raise Firebrew::ExtensionNotFoundError, "Extension not found: #{name}" if result.nil?
        result
      end
      
      def install(extension, is_displaying_progress = false)
        dir = File.join(self.profile.path, 'extensions')
        FileUtils.mkdir_p dir
        xpi_path = '%s.xpi' % File.join(dir, extension.guid)
        
        File.open(xpi_path,'wb') do |out|
          uri = [extension.uri].flatten.first
          pout = is_displaying_progress ? $stdout : nil
          Firebrew::Downloader.new(uri, out, output: pout).exec
        end
        
        xpi = Zip::File.open(File.open(xpi_path,'rb'))
        install_manifests = xpi.find_entry('install.rdf')
        install_manifests = install_manifests.get_input_stream.read
        install_manifests = REXML::Document.new(install_manifests)
        is_unpacking = REXML::XPath.match(install_manifests, '/RDF/Description/em:unpack/text()').first
        is_unpacking = is_unpacking.nil? ? false : is_unpacking.value.strip == 'true'
        
        if is_unpacking then
          extension.uri = xpi_path.pathmap('%X')
          FileUtils.mkdir_p(extension.uri)
          
          xpi.each do |entry|
            next if entry.ftype == :directory
            content = entry.get_input_stream.read
            Dir.chdir(extension.uri) do
              FileUtils.mkdir_p File.dirname(entry.name)
              File.write(entry.name, content)
            end
          end
          
          xpi.close
          FileUtils.rm_rf(xpi_path)
        else
          extension.uri = xpi_path
          xpi.close
        end
        
        self.add(extension)
        self.push
      end
      
      def uninstall(extension)
        FileUtils.rm_r extension.uri
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
        return @data unless @data.nil?
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
          'descriptor'=> extension.uri,
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

require 'inifile'
require 'firebrew/firefox/extension'

module Firebrew::Firefox
  class Profile
    include Firebrew::Entity
    
    class Manager
      def initialize(params={})
        @base_dir = params[:base_dir]
        @data_file = params[:data_file] || 'profiles.ini'
        raise Firebrew::ProfilesFileNotFoundError unless File.exists? self.data_path
      end
      
      def all
        sections = IniFile.load(self.data_path).to_h
        profiles = sections.find_all{|(name,prop)| name.match(/^Profile\d+$/)}
        profiles.map do |(name,prop)|
          Profile.new(
            name: prop['Name'],
            path: self.profile_path(prop['Path'], prop['IsRelative'] == '1'),
            is_default: prop['Default'] == '1',
          )
        end
      end
      
      def find(name)
        self.all.find{|p| p.name == name }
      end
      
      def find!(name)
        result = self.find(name)
        raise Firebrew::ProfileNotFoundError if result.nil?
        result
      end
      
      protected
      
      def data_path
        File.expand_path File.join(@base_dir, @data_file)
      end
      
      def profile_path(path, is_relative)
        path = is_relative ? File.join(@base_dir, path) : path 
        File.expand_path path
      end
    end
    
    entity_attr :name, :path, :is_default
    
    def extensions
      Extension::Manager.new(profile: self)
    end
  end
end

require 'active_model'
require 'inifile'
require 'firebrew/firefox/extension'

module Firebrew::Firefox
  class Profile
    include ActiveModel::Model
    
    class Manager
      def initialize(params={})
        @base_dir = params[:base_dir]
        @data_file = params[:data_file] || 'profiles.ini'
      end
      
      def all
        sections = IniFile.load(File.join @base_dir, @data_file).to_h
        profiles = sections.find_all{|(name,prop)| name.match(/^Profile\d+$/)}
        profiles.map do |(name,prop)|
          Profile.new(
            name: prop['Name'],
            path: prop['IsRelative'] == '1' ?
              File.join(@base_dir, prop['Path']) : prop['Path'],
            is_default: prop['Default'] == '1',
          )
        end
      end
      
      def find(name)
        self.all.find{|p| p.name == name }
      end
    end
    
    attr_accessor :name, :path, :is_default
    
    def extensions
      Extension::Manager.new(profile: self)
    end
  end
end

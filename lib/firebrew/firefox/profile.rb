require 'active_model'
require 'inifile'

module Firebrew::Firefox
  class Profile
    include ActiveModel::Model
    
    def self.fetch(params={})
      sections = IniFile.load(File.join params[:base_dir], params[:data_file]).to_h
      profiles = sections.find_all{|(name,prop)| name.match(/^Profile\d+$/)}
      profiles.map do |(name,prop)|
        Profile.new(
          name: prop['Name'],
          path: prop['IsRelative'] == '1' ?
            File.join(params[:base_dir], prop['Path']) : prop['Path'],
          is_default: prop['Default'] == '1',
        )
      end
    end
    
    attr_accessor :name, :path, :is_default
  end
end

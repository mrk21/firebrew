require 'fileutils'
require 'firebrew/firefox/basic_extension'

module Firebrew::Firefox
  class Extension < BasicExtension
    class Manager
      attr_reader :profile
      
      def initialize(params={})
        @profile = params[:profile]
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
    end
  end
end

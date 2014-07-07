$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'firebrew'
require 'fileutils'

RSpec.configure do |config|
  config.before(:all) do
    FileUtils.mkdir_p './tmp'
  end
  
  config.after(:all) do
    FileUtils.rm_rf './tmp'
  end
end

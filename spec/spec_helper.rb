$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'firebrew'
require 'fileutils'

FileUtils.rm_rf './tmp'
FileUtils.mkdir_p './tmp'

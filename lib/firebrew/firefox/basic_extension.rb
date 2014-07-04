require 'active_model'

module Firebrew::Firefox
  class BasicExtension
    include ActiveModel::Model
    attr_accessor :name, :guid, :version, :uri
  end
end

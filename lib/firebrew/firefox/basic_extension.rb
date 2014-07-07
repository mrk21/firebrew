require 'firebrew/entity'
require 'active_model'

module Firebrew::Firefox
  class BasicExtension
    include ActiveModel::Model
    include Firebrew::Entity
    entity_attr :name, :guid, :version, :uri
  end
end

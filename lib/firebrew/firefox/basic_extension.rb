require 'firebrew/entity'

module Firebrew::Firefox
  class BasicExtension
    include Firebrew::Entity
    entity_attr :name, :guid, :version, :uri
  end
end

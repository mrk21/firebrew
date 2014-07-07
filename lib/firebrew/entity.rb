module Firebrew
  module Entity
    def self.included(base)
      base.class_eval do
        @@attributes = []
        
        def self.entity_attr(*attrs)
          @@attributes.push(*attrs).uniq
          attr_accessor *attrs
        end
        
        def ==(b)
          @@attributes.each do|attr|
            return false unless self.send(attr) == b.send(attr)
          end
          return true
        end
        
        alias :eql? :==
      end
    end
  end
end

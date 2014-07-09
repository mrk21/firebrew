module Firebrew
  module Entity
    def self.included(base)
      base.class_eval do
        extend ClassMethod
      end
      base.attributes = []
    end
    
    module ClassMethod
      attr_accessor :attributes
      
      def entity_attr(*attrs)
        self.attributes.push(*attrs).uniq
        attr_accessor *attrs
      end
    end
    
    def ==(rop)
      self.class.attributes.each do|attr|
        return false unless self.send(attr) == rop.send(attr)
      end
      return true
    end
    
    alias :eql? :==
  end
end

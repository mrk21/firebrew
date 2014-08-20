module Firebrew
  module Entity
    def self.included(base)
      base.class_eval do
        extend ClassMethod
      end
    end
    
    module ClassMethod
      attr_accessor :attributes
      
      def self.extended(base)
        base.attributes = []
      end
      
      def inherited(base)
        base.attributes = self.attributes.clone
      end
      
      def entity_attr(*attrs)
        attrs.uniq!
        common = self.attributes & attrs
        adding = attrs - common
        self.attributes.push(*adding)
        attr_accessor *adding
        adding
      end
    end
    
    def initialize(attributes={})
      attributes.each do |(k,v)|
        self.send("#{k}=", v)
      end
    end
    
    def ==(rop)
      self.class.attributes.each do |attr|
        return false unless self.send(attr) == rop.send(attr)
      end
      return true
    end
    
    alias :eql? :==
  end
end

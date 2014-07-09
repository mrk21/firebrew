require 'spec_helper'

module Firebrew
  class EntityTest1
    include Entity
    entity_attr :value1, :value2
    def initialize(params={})
      params.each{|(k,v)| self.send("#{k}=", v) }
    end
  end
  
  class EntityTest2
    include Entity
    entity_attr :value3, :value4
  end
  
  describe Firebrew::Entity do
    describe '::attributes()' do
      describe 'EntityTest1(value1, value2)' do
        it { expect(EntityTest1.attributes).to eq([:value1, :value2]) }
      end
      
      describe 'EntityTest2(value3, value4)' do
        it { expect(EntityTest2.attributes).to eq([:value3, :value4]) }
      end
    end
    
    describe '#==(rop)' do
      context 'when `self` equaled `rop`' do
        it do
          a = EntityTest1.new(value1: 1, value2: 2)
          b = EntityTest1.new(value1: 1, value2: 2)
          expect(a == b).to be_truthy
        end
      end
      
      context 'when `self` not equaled `rop`' do
        it do
          a = EntityTest1.new(value1: 1, value2: 2)
          b = EntityTest1.new(value1: 3, value2: 2)
          expect(a == b).to be_falsy
        end
      end
    end
  end
end

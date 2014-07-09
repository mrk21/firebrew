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
  
  class EntityTest1Ex < EntityTest1
    entity_attr :value5, :value6
  end
  
  describe Firebrew::Entity do
    describe '::attributes()' do
      describe 'EntityTest1(value1, value2)' do
        it { expect(EntityTest1.attributes).to eq([:value1, :value2]) }
      end
      
      describe 'EntityTest2(value3, value4)' do
        it { expect(EntityTest2.attributes).to eq([:value3, :value4]) }
      end
      
      describe 'EntityTest1Ex(value1, value2, value5, value6)' do
        it { expect(EntityTest1Ex.attributes).to eq([:value1, :value2, :value5, :value6]) }
      end
    end
    
    describe '::entity_attr(*attrs)' do
      subject do
        Class.new do
          include Entity
        end
      end
      
      it 'should add the `attrs`' do
        expect(subject.entity_attr(:attr1, :attr2)).to eq([:attr1, :attr2])
      end
      
      context 'when the `attrs` was already existed' do
        it 'should add attributes which not exist in the `::attributes`' do
          subject.entity_attr(:attr1)
          expect(subject.entity_attr(:attr1, :attr2)).to eq([:attr2])
        end
      end
      
      context 'when the `attrs` contain duplicate values' do
        it 'should add attributes which not contain duplicate values' do
          expect(subject.entity_attr(:attr1, :attr2, :attr2)).to eq([:attr1, :attr2])
        end
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

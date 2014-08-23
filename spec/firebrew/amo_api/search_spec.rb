require 'spec_helper'

module Firebrew::AmoApi
  describe Firebrew::AmoApi::Search do
    before do
      response = File.read("spec/fixtures/amo_api/search/#{self.fixture}")
      
      Search.connection = double(:connection)
      allow(Search.connection).to receive(:get).and_return(OpenStruct.new body: response)
    end
    
    after do
      Search.connection = nil
    end
    
    let(:fixture){'base.xml'}
    
    describe '::fetch(params)' do
      subject{Search.fetch term: ''}
      
      it { is_expected.to be_instance_of(Array) }
      it { expect(subject.size).to eq(3) }
      
      it 'should construct objects' do
        expect(subject[0].guid).to eq('hoge-ja@example.org')
        expect(subject[0].name).to eq('hoge')
        
        expect(subject[1].guid).to eq('hoge-fuga-ja@example.org')
        expect(subject[1].name).to eq('hoge_fuga')
        
        expect(subject[2].guid).to eq('hoge-hoge-ja@example.org')
        expect(subject[2].name).to eq('hoge_hoge')
      end
      
      context 'when results were empty' do
        let(:fixture){'empty.xml'}
        it { is_expected.to be_instance_of(Array) }
        it { expect(subject.size).to eq(0) }
      end
      
      context 'when the number of results was one' do
        let(:fixture){'single.xml'}
        
        it { is_expected.to be_instance_of(Array) }
        it { expect(subject.size).to eq(1) }
        
        it 'should construct objects' do
          expect(subject[0].guid).to eq('hoge-ja@example.org')
          expect(subject[0].name).to eq('hoge')
        end
      end
    end
    
    describe '::fetch!(params)' do
      subject {Search.fetch! term: 'aa'}
      
      it { is_expected.to be_instance_of(Array) }
      it { expect(subject.size).to eq(3) }
      it { expect{subject}.to_not raise_error }
      
      context 'when results were empty' do
        let(:fixture){'empty.xml'}
        it { expect{subject}.to raise_error(Firebrew::ExtensionNotFoundError, 'Extension not found: like "aa"') }
      end
    end
  end
end

require 'spec_helper'

module Firebrew::AmoApi
  describe Firebrew::AmoApi::Search do
    before do
      response = File.read("spec/fixtures/amo_api/search/#{self.fixture}")
      
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get Search.path(self.params), {}, response
      end
    end
    
    after do
      ActiveResource::HttpMock.reset!
    end
    
    let(:params){{term: 'hoge'}}
    let(:fixture){'base.xml'}
    
    describe '::fetch(params)' do
      subject{Search.fetch self.params}
      
      it { is_expected.to be_instance_of(Array) }
      it { expect(subject.size).to eq(3) }
      
      it 'should construct objects' do
        expect(subject[0].id).to eq('100')
        expect(subject[0].name).to eq('hoge')
        
        expect(subject[1].id).to eq('101')
        expect(subject[1].name).to eq('hoge_fuga')
        
        expect(subject[2].id).to eq('102')
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
          expect(subject[0].id).to eq('100')
          expect(subject[0].name).to eq('hoge')
        end
      end
    end
    
    describe '::fetch!(params)' do
      subject {Search.fetch! self.params}
      
      it { is_expected.to be_instance_of(Array) }
      it { expect(subject.size).to eq(3) }
      it { expect{subject}.to_not raise_error }
      
      context 'when results were empty' do
        let(:fixture){'empty.xml'}
        it { expect{subject}.to raise_error(Firebrew::ExtensionNotFoundError) }
      end
    end
  end
end

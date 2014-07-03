require 'spec_helper'


module Firebrew::AmoApi
  describe Firebrew::AmoApi::Search do
    subject{Search.fetch self.params}
    let(:params){{term: 'hoge'}}
    let(:fixture){'base.xml'}
    
    before do
      response = File.read("spec/fixtures/amo_api/search/#{self.fixture}")
      
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get Search.path(self.params), {}, response
      end
    end
    
    after do
      ActiveResource::HttpMock.reset!
    end
    
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
      it { expect(subject.size).to eq(0) }
    end
  end
end

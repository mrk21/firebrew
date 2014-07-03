require 'spec_helper'

module Firebrew::Firefox
  describe Firebrew::Firefox::Profile do
    describe '::fetch()' do
      subject do
        Profile.fetch(
          base_dir: self.base_dir,
          data_file: self.data_file
        )
      end
      let(:base_dir){'./spec/fixtures/firefox/profile'}
      let(:data_file){'base.ini'}
      
      it { expect(subject.size).to eq(3) }
      
      it 'should construct records' do
        expect(subject[0].name).to eq('default')
        expect(subject[0].path).to eq(File.join(self.base_dir, 'Profiles/abcd.default'))
        expect(subject[0].is_default).to be_truthy
        
        expect(subject[1].name).to eq('other_profile')
        expect(subject[1].path).to eq(File.join(self.base_dir, 'Profiles/efgh.other_profile'))
        expect(subject[1].is_default).to be_falsey
        
        expect(subject[2].name).to eq('abs_profile')
        expect(subject[2].path).to eq('/path/to/abs_profile')
        expect(subject[2].is_default).to be_falsey
      end
      
      context 'when profiles were empty' do
        let(:data_file){'empty.ini'}
        it { is_expected.to be_empty }
      end
    end
  end
end

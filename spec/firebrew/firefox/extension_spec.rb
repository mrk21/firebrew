require 'spec_helper'

module Firebrew::Firefox
  describe Firebrew::Firefox::Extension do
    describe :Manager do
      subject { self.instance }
      
      let(:instance) do
        Extension::Manager.new(
          profile: Profile.new(
            path: './tmp'
          )
        )
      end
      
      describe '#install(extension)' do
        subject { super().install(self.extension) }
        
        let(:extension) do
          BasicExtension.new(
            guid: 'hoge@example.org',
            uri: './spec/fixtures/amo_api/search/base.xml'
          )
        end
        
        it { is_expected.to be_truthy }
        it 'should copy the `path/to/profile/extensions/guid.xpi`' do
          path = File.join(self.instance.profile.path, 'extensions/%s.xpi' % self.extension.guid)
          expect(File.exists? path).to be_truthy
        end
      end
    end
  end
end

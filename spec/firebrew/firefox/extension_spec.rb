require 'spec_helper'
require 'fileutils'

module Firebrew::Firefox
  describe Firebrew::Firefox::Extension do
    let(:manager) do
      Extension::Manager.new(
        profile: Profile.new(
          path: './tmp'
        )
      )
    end
    
    let(:extensions){[
      Extension.new(
        name: 'Japanese Language Pack',
        guid: 'langpack-ja@firefox.mozilla.org',
        version: '30.0',
        uri: './tmp/extensions/langpack-ja@firefox.mozilla.org.xpi'
      ),
      Extension.new(
        name: 'Vimperator',
        guid: 'vimperator@mozdev.org',
        version: '3.8.2',
        uri: './tmp/extensions/vimperator@mozdev.org.xpi'
      )
    ]}
    
    before do
      FileUtils.cp('./spec/fixtures/firefox/extension/extensions.v16.json', './tmp/extensions.json')
    end
    
    describe :Manager do
      subject { self.instance }
      let(:instance){self.manager}
      
      describe '#all()' do
        subject { self.instance.all }
        
        it { is_expected.to be_instance_of(Array) }
        it { expect(subject.size).to eq(2) }
        
        it 'should construct' do
          expect(subject[0]).to eq(self.extensions[0])
          expect(subject[1]).to eq(self.extensions[1])
        end
        
        context 'when not existed `extension.json`' do
          before {FileUtils.rm_f './tmp/extensions.json'}
          it { expect{subject}.to raise_error(Firebrew::ExtensionsFileNotFoundError) }
        end
      end
      
      describe '#find(name)' do
        subject {super().find self.name}
        let(:name){self.extensions[1].name}
        
        it { is_expected.to eq(self.extensions[1]) }
        
        context 'when the extension corresponding to the `name` not existed' do
          let(:name){'hoge'}
          it { is_expected.to be_nil }
        end
      end
      
      describe '#find!(name)' do
        subject {super().find! self.name}
        let(:name){self.extensions[1].name}
        
        it { is_expected.to eq(self.extensions[1]) }
        it { expect{subject}.to_not raise_error }
        
        context 'when the extension corresponding to the `name` not existed' do
          let(:name){'hoge'}
          it { expect{subject}.to raise_error(Firebrew::ExtensionNotFoundError) }
        end
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
    
    describe 'instance' do
      subject {self.instance}
      let(:instance){self.extensions[1]}
      
      before do
        open(self.instance.uri,'w'){|o| o.write self.instance.name}
      end
      
      after do
        FileUtils.rm_f self.instance.uri
      end
      
      describe '#delete()' do
        before do
          self.instance().delete
        end
        
        it 'should not existed this file' do
          expect(File.exists? self.instance.uri).to be_falsey
        end
      end
    end
  end
end

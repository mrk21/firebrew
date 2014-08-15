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
      Extension.new({
        name: 'Japanese Language Pack',
        guid: 'langpack-ja@firefox.mozilla.org',
        version: '30.0',
        uri: './tmp/extensions/langpack-ja@firefox.mozilla.org.xpi'
      }, self.manager),
      Extension.new({
        name: 'Vimperator',
        guid: 'vimperator@mozdev.org',
        version: '3.8.2',
        uri: './tmp/extensions/vimperator@mozdev.org.xpi'
      }, self.manager)
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
          before do
            FileUtils.rm_f './tmp/extensions.json'
            subject
          end
          
          it 'should create that' do
            expect(File.exists? './tmp/extensions.json').to be_truthy
          end
        end
      end
      
      describe '#find(name)' do
        subject {super().find self.name}
        let(:name){self.extensions[1].name}
        
        it 'should find' do
          is_expected.to eq(self.extensions[1])
        end
        
        context 'when the extension corresponding to the `name` not existed' do
          let(:name){'hoge'}
          it { is_expected.to be_nil }
        end
      end
      
      describe '#find!(name)' do
        subject {super().find! self.name}
        let(:name){self.extensions[1].name}
        
        it { expect{subject}.to_not raise_error }
        it 'should find' do
          is_expected.to eq(self.extensions[1])
        end
        
        context 'when the extension corresponding to the `name` not existed' do
          let(:name){'hoge'}
          it { expect{subject}.to raise_error(Firebrew::ExtensionNotFoundError) }
        end
      end
      
      describe '#install(extension)' do
        subject { self.instance.install(self.extension) }
        
        let(:extension) do
          Extension.new({
            guid: 'hoge@example.org',
            uri: './spec/fixtures/amo_api/search/base.xml'
          }, self.manager)
        end
        
        it 'should copy the `path/to/profile/extensions/guid.xpi`' do
          subject
          path = File.join(self.instance.profile.path, 'extensions/%s.xpi' % self.extension.guid)
          expect(File.exists? path).to be_truthy
        end
        
        it 'should add the `extension` extension' do
          subject
          all = self.instance.all
          extension = self.extension
          extension.uri = './tmp/extensions/hoge@example.org.xpi'
          expect(all.size).to eq(3)
          expect(all[0]).to eq(self.extensions[0])
          expect(all[1]).to eq(self.extensions[1])
          expect(all[2]).to eq(self.extension)
        end
        
        context 'when an `uri` of the `extension` was equal or greater than two' do
          let(:extension) do
            Extension.new({
              guid: 'hoge@example.org',
              uri: [
                './spec/fixtures/amo_api/search/base.xml',
                './spec/fixtures/amo_api/search/not_exists.xml'
              ]
            }, self.manager)
          end
          
          it 'should not throw exceptions' do
            expect{subject}.to_not raise_error
          end
        end
      end
      
      describe '#uninstall(extension)' do
        let(:extension) do
          Extension.new({
            guid: 'hoge@example.org',
            uri: './tmp/extensions/hoge@example.org.xpi'
          }, self.manager)
        end
        
        before do
          FileUtils.cp('./spec/fixtures/firefox/extension/extensions_added_hoge.v16.json', './tmp/extensions.json')
          File.write self.extension.uri, ''
          self.manager.uninstall(self.extension)
        end
        
        it 'should remove the `extension` file' do
          expect(File.exists? self.extension.uri).to be_falsey
        end
        
        it 'should remove the `extension` extension' do
          all = self.instance.all
          expect(all.size).to eq(2)
          expect(all[0]).to eq(self.extensions[0])
          expect(all[1]).to eq(self.extensions[1])
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

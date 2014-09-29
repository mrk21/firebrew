require 'spec_helper'
require 'fileutils'
require 'digest/md5'

module Firebrew::Firefox
  describe Firebrew::Firefox::Extension do
    let(:manager) do
      Extension::Manager.new(
        profile: Profile.new(
          path: File.join(Dir.pwd, 'tmp')
        )
      )
    end
    
    let(:extensions){[
      Extension.new({
        name: 'Japanese Language Pack',
        guid: 'langpack-ja@firefox.mozilla.org',
        version: '30.0',
        uri: File.join(Dir.pwd, 'tmp/extensions/langpack-ja@firefox.mozilla.org.xpi')
      }, self.manager),
      Extension.new({
        name: 'Vimperator',
        guid: 'vimperator@mozdev.org',
        version: '3.8.2',
        uri: File.join(Dir.pwd, 'tmp/extensions/vimperator@mozdev.org.xpi')
      }, self.manager)
    ]}
    
    before do
      json = File.read('./spec/fixtures/firefox/extension/extensions.v16.json')
      File.write('./tmp/extensions.json', json % {profile_path: self.manager.profile.path})
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
          it { expect{subject}.to raise_error(Firebrew::ExtensionNotFoundError, 'Extension not found: hoge') }
        end
      end
      
      describe '#install(extension[, is_displaying_progress])' do
        subject { self.instance.install(self.extension) }
        
        let(:extension) do
          Extension.new({guid: 'hoge@example.org', uri: self.extension_uri}, self.manager)
        end
        
        let(:extension_uri) do
          './spec/fixtures/firefox/extension/unpack_false.xpi'
        end
        
        let(:expected_path) do
          File.join(self.instance.profile.path, 'extensions/%s.xpi' % self.extension.guid)
        end
        
        it 'should copy the `path/to/profile/extensions/<GUID>.xpi`' do
          subject
          md5, path = File.read(self.extension_uri.pathmap('%X.md5')).split(/\s+/)
          expect(Digest::MD5.hexdigest(File.read self.expected_path)).to eq(md5)
        end
        
        it 'should add the `extension` extension' do
          subject
          all = self.instance.all
          extension = self.extension
          extension.uri = File.join(Dir.pwd, 'tmp/extensions/hoge@example.org.xpi')
          expect(all.size).to eq(3)
          expect(all[0]).to eq(self.extensions[0])
          expect(all[1]).to eq(self.extensions[1])
          expect(all[2]).to eq(self.extension)
        end
        
        context 'when an `uri` of the `extension` was equal or greater than two' do
          let(:extension) do
            Extension.new({guid: 'hoge@example.org', uri: self.extension_uri}, self.manager)
          end
          
          let(:extension_uri) do
            [
              './spec/fixtures/firefox/extension/unpack_false.xpi',
              './spec/fixtures/firefox/extension/not_exists.xpi'
            ]
          end
          
          it 'should not throw exceptions' do
            expect{subject}.to_not raise_error
          end
        end
        
        context 'when an `em:unpack` value of the `install.rdf` in the XPI package not exsisted' do
          let(:extension) do
            Extension.new({guid: 'hoge@example.org', uri: self.extension_uri}, self.manager)
          end
          
          let(:extension_uri) do
            './spec/fixtures/firefox/extension/unpack_null.xpi'
          end
          
          it 'should copy the `path/to/profile/extensions/<GUID>.xpi`' do
            subject
            md5, path = File.read(self.extension_uri.pathmap('%X.md5')).split(/\s+/)
            expect(Digest::MD5.hexdigest(File.read self.expected_path)).to eq(md5)
          end
          
          it 'should add the `extension` extension' do
            subject
            all = self.instance.all
            extension = self.extension
            extension.uri = File.join(Dir.pwd, 'tmp/extensions/hoge@example.org.xpi')
            expect(all.size).to eq(3)
            expect(all[0]).to eq(self.extensions[0])
            expect(all[1]).to eq(self.extensions[1])
            expect(all[2]).to eq(self.extension)
          end
        end
        
        context 'when an `em:unpack` value of the `install.rdf` in the XPI package was true' do
          let(:extension) do
            Extension.new({guid: 'hoge@example.org', uri: self.extension_uri}, self.manager)
          end
          
          let(:extension_uri) do
            './spec/fixtures/firefox/extension/unpack_true.xpi'
          end
          
          let(:expected_path) do
            File.join(self.instance.profile.path, 'extensions/%s' % self.extension.guid)
          end
          
          it 'should copy the `path/to/profile/extensions/<GUID>`' do
            subject
            expect(File.exists? self.expected_path).to be_truthy
          end
          
          it 'should unzip all files in the XPI package' do
            subject
            md5list = File.read(self.extension_uri.pathmap('%X.md5'))
            Dir.chdir(self.expected_path) do
              md5list.each_line do |item|
                md5, path = item.split(/\s+/)
                expect(Digest::MD5.hexdigest(File.read path)).to eq(md5)
              end
            end
          end
          
          it 'should add the `extension` extension' do
            subject
            all = self.instance.all
            extension = self.extension
            extension.uri = File.join(Dir.pwd, 'tmp/extensions/hoge@example.org')
            expect(all.size).to eq(3)
            expect(all[0]).to eq(self.extensions[0])
            expect(all[1]).to eq(self.extensions[1])
            expect(all[2]).to eq(self.extension)
          end
        end
      end
      
      describe '#uninstall(extension)' do
        let(:extension) do
          Extension.new({
            guid: 'hoge@example.org',
            uri: File.join(Dir.pwd, 'tmp/extensions/hoge@example.org.xpi')
          }, self.manager)
        end
        
        let(:create_xpi_block){->{
          File.write self.extension.uri, ''
        }}
        
        before do
          json = File.read('./spec/fixtures/firefox/extension/extensions_added_hoge.v16.json')
          File.write('./tmp/extensions.json', json % {profile_path: self.manager.profile.path})
          self.create_xpi_block[]
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
        
        context 'when `em:unpack` value of the `install.rdf` in the `extension` was true' do
          let(:extension) do
            Extension.new({
              guid: 'hoge@example.org',
              uri: File.join(Dir.pwd, 'tmp/extensions/hoge@example.org')
            }, self.manager)
          end
          
          let(:create_xpi_block){->{
            FileUtils.mkdir_p self.extension.uri
          }}
          
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

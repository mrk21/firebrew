require 'spec_helper'

module Firebrew
  describe Firebrew::Runner do
    describe '::default_config(platform)' do
      subject do
        Runner.default_config(self.platform)
      end
      
      let(:platform){RUBY_PLATFORM}
      
      before do
        ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'] = nil
        ENV['FIREBREW_FIREFOX_PROFILE'] = nil
        ENV['FIREBREW_FIREFOX'] = nil
      end
      
      context 'when the `platform` was "MacOS"' do
        let(:platform){'x86_64-darwin13.0'}
        it do
          is_expected.to eq(
            base_dir: '~/Library/Application Support/Firefox',
            firefox: '/Applications/Firefox.app/Contents/MacOS/firefox-bin',
            profile: 'default'
          )
        end
      end
      
      context 'when the `platform` was "Linux"' do
        let(:platform){'x86_64-linux'}
        it do
          is_expected.to eq(
            base_dir: '~/.mozilla/firefox',
            firefox: '/usr/bin/firefox',
            profile: 'default'
          )
        end
      end
      
      context 'when the `platform` was "Windows 7 x86_64"' do
        let(:platform){'x64-mingw32'}
        it do
          is_expected.to eq(
            base_dir: '~/AppData/Roming/Mozilla/Firefox',
            firefox: 'C:/Program Files (x86)/Mozilla Firefox/firefox.exe',
            profile: 'default'
          )
        end
      end
      
      context 'when set environment variables' do
        before do
          ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'] = 'path/to/profile_base_directory'
          ENV['FIREBREW_FIREFOX_PROFILE'] = 'profile-name'
          ENV['FIREBREW_FIREFOX'] = 'path/to/firefox'
        end
        
        after do
          ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'] = nil
          ENV['FIREBREW_FIREFOX_PROFILE'] = nil
          ENV['FIREBREW_FIREFOX'] = nil
        end
        
        it do
          is_expected.to eq(
            base_dir: 'path/to/profile_base_directory',
            firefox: 'path/to/firefox',
            profile: 'profile-name'
          )
        end
      end
    end
    
    describe :Instance do
      subject {self.instance}
      
      let(:instance) do
        Runner.new(
          base_dir: './tmp',
          data_file: 'profiles.ini',
          firefox: './spec/double/firefox.rb'
        )
      end
      
      let(:search_params){{term: 'hoge', version: '30.0', max: 1}}
      
      before do
        FileUtils.cp './spec/fixtures/firefox/profile/base.ini', './tmp/profiles.ini'
        response = File.read("./spec/fixtures/amo_api/search/base.xml")
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get AmoApi::Search.path(self.search_params), {}, response
        end
      end
      
      after do
        FileUtils.rm_f './tmp/*'
        ActiveResource::HttpMock.reset!
      end
      
      describe '#install(params)' do
        subject do
          extensions_double = double('extensions', install: nil, find: nil)
          self.instance.profile = double('profile', extensions: extensions_double)
          self.instance.install(self.search_params)
        end
        
        it { expect{subject}.to_not raise_error }
        
        context 'when the `params[:term]` existed' do
          subject do
            extensions_double = double('extensions', install: nil, find: Firefox::BasicExtension.new)
            self.instance.profile = double('profile', extensions: extensions_double)
            self.instance.install(self.search_params)
          end
          
          it { expect{subject}.to raise_error(Firebrew::OperationAlreadyCompletedError) }
        end
      end
      
      describe '#uninstall(params)' do
        subject do
          extensions_double = double('extensions', find!: double('ext', delete: nil))
          self.instance.profile = double('profile', extensions: extensions_double)
          self.instance.uninstall(term: 'not-existed-extension')
        end
        
        it { expect{subject}.to_not raise_error }
        
        context 'when the `params[:term]` not existed' do
          subject do
            extensions_double = double('extensions')
            allow(extensions_double).to receive(:find!).and_raise(Firebrew::ExtensionNotFoundError)
            self.instance.profile = double('profile', extensions: extensions_double)
            self.instance.uninstall(term: 'not-existed-extension')
          end
          
          it { expect{subject}.to raise_error(Firebrew::OperationAlreadyCompletedError) }
        end
      end
    end
  end
end

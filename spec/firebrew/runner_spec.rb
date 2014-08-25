require 'spec_helper'

module Firebrew
  describe Firebrew::Runner do
    describe '::default_config(platform)' do
      subject do
        Runner.default_config(self.platform)
      end
      
      let(:platform){'x86_64-darwin13.0'}
      
      before do
        ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'] = nil
        ENV['FIREBREW_FIREFOX_PROFILE'] = nil
        ENV['FIREBREW_FIREFOX'] = nil
      end
      
      after do
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
            profile: 'default',
            os: 'darwin'
          )
        end
      end
      
      context 'when the `platform` was "Linux"' do
        let(:platform){'x86_64-linux'}
        it do
          is_expected.to eq(
            base_dir: '~/.mozilla/firefox',
            firefox: '/usr/bin/firefox',
            profile: 'default',
            os: 'linux'
          )
        end
      end
      
      context 'when the `platform` was "Windows"' do
        let(:platform){'x64-mingw32'}
        
        before do
          ENV['APPDATA'] = nil
          ENV['PROGRAMFILES'] = nil
          ENV['PROGRAMFILES(X86)'] = nil
        end
        
        after do
          ENV['APPDATA'] = nil
          ENV['PROGRAMFILES'] = nil
          ENV['PROGRAMFILES(X86)'] = nil
        end
        
        context 'when the ruby architecture was "x86"' do
          context 'when the `platform` was "Windows 7 x86_64"' do
            before do
              ENV['APPDATA'] = 'C:\Users\admin\AppData\Roaming'
              ENV['PROGRAMFILES'] = 'C:\Program Files (x86)'
              ENV['PROGRAMFILES(X86)'] = 'C:\Program Files (x86)'
            end
            
            it do
              is_expected.to eq(
                base_dir: 'C:/Users/admin/AppData/Roaming/Mozilla/Firefox',
                firefox: 'C:/Program Files (x86)/Mozilla Firefox/firefox.exe',
                profile: 'default',
                os: 'winnt'
              )
            end
          end
          
          context 'when the `platform` was "Windows XP x86"' do
            before do
              ENV['APPDATA'] = 'C:\Documents and Settings\Administrator\Application Data'
              ENV['PROGRAMFILES'] = 'C:\Program Files'
              ENV['PROGRAMFILES(X86)'] = nil
            end
            
            it do
              is_expected.to eq(
                base_dir: 'C:/Documents and Settings/Administrator/Application Data/Mozilla/Firefox',
                firefox: 'C:/Program Files/Mozilla Firefox/firefox.exe',
                profile: 'default',
                os: 'winnt'
              )
            end
          end
        end
        
        context 'when the ruby architecture was "X86_64"' do
          context 'when the `platform` was "Windows 7 x86_64"' do
            before do
              ENV['APPDATA'] = 'C:\Users\admin\AppData\Roaming'
              ENV['PROGRAMFILES'] = 'C:\Program Files'
              ENV['PROGRAMFILES(X86)'] = 'C:\Program Files (x86)'
            end
            
            it do
              is_expected.to eq(
                base_dir: 'C:/Users/admin/AppData/Roaming/Mozilla/Firefox',
                firefox: 'C:/Program Files (x86)/Mozilla Firefox/firefox.exe',
                profile: 'default',
                os: 'winnt'
              )
            end
          end
        end
      end
      
      context 'when set environment variables' do
        before do
          ENV['FIREBREW_FIREFOX_PROFILE_BASE_DIR'] = 'path/to/profile_base_directory'
          ENV['FIREBREW_FIREFOX_PROFILE'] = 'profile-name'
          ENV['FIREBREW_FIREFOX'] = 'path/to/firefox'
        end
        
        it do
          is_expected.to eq(
            base_dir: 'path/to/profile_base_directory',
            firefox: 'path/to/firefox',
            profile: 'profile-name',
            os: 'darwin'
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
          firefox: ENV['OS'].nil? ? './spec/double/firefox.rb' : './spec/double/firefox.bat'
        )
      end
      
      let(:search_params){{term: 'hoge', version: '30.0', max: 1, os: Runner.default_config[:os]}}
      
      before do
        FileUtils.cp './spec/fixtures/firefox/profile/base.ini', './tmp/profiles.ini'
        response = File.read("./spec/fixtures/amo_api/search/base.xml")
        AmoApi::Search.connection = double(:connection)
        allow(AmoApi::Search.connection).to receive(:get).and_return(OpenStruct.new body: response, status: 200)
      end
      
      after do
        FileUtils.rm_f './tmp/*'
        AmoApi::Search.connection = nil
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
            extensions_double = double('extensions', install: nil, find: Firefox::BasicExtension.new(name: self.extension_name))
            self.instance.profile = double('profile', extensions: extensions_double)
            self.instance.install(self.search_params)
          end
          
          let(:extension_name){'hoge'}
          
          it { expect{subject}.to raise_error(Firebrew::OperationAlreadyCompletedError, "Already installed: #{self.extension_name}") }
        end
      end
      
      describe '#uninstall(params)' do
        subject do
          extensions_double = double('extensions', find!: double('ext', delete: nil))
          self.instance.profile = double('profile', extensions: extensions_double)
          self.instance.uninstall(term: self.extension_name)
        end
        
        let(:extension_name){'existed-extension'}
        
        it { expect{subject}.to_not raise_error }
        
        context 'when the `params[:term]` not existed' do
          subject do
            extensions_double = double('extensions')
            allow(extensions_double).to receive(:find!).and_raise(Firebrew::ExtensionNotFoundError)
            self.instance.profile = double('profile', extensions: extensions_double)
            self.instance.uninstall(term: self.extension_name)
          end
          
          let(:extension_name){'not-existed-extension'}
          
          it { expect{subject}.to raise_error(Firebrew::OperationAlreadyCompletedError, "Already uninstalled: #{self.extension_name}") }
        end
      end
    end
  end
end

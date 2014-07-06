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
        
        it do
          is_expected.to eq(
            base_dir: 'path/to/profile_base_directory',
            firefox: 'path/to/firefox',
            profile: 'profile-name'
          )
        end
      end
    end
  end
end

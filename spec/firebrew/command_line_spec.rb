require 'spec_helper'

module Firebrew
  describe Firebrew::CommandLine do
    subject do
      CommandLine.new(self.args.split(/\s+/))
    end
    let(:args){''}
    
    describe '::default_global_options(platform)' do
      subject do
        CommandLine.default_global_options(self.platform)
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
    
    describe 'commandline arguments parsing' do
      subject { super().config }
      
      describe 'install command' do
        let(:args){'install addon-name'}
        
        it 'should parse' do
          is_expected.to eq(
            command: :install,
            options: {
              package: 'addon-name'
            },
            global_options: CommandLine.default_global_options
          )
        end
        
        context 'with options' do
          let(:args){'--base-dir=/path/to/dir install -p default addon-name -v 2.3 --type=extension --version=5.4.4 --profile=test --firefox=/path/to/firefox'}
          
          it 'should parse' do
            is_expected.to eq(
              command: :install,
              options: {
                package: 'addon-name',
                version: '5.4.4',
                type: 'extension'
              },
              global_options: {
                base_dir: '/path/to/dir',
                profile: 'test',
                firefox: '/path/to/firefox'
              }
            )
          end
        end
        
        context 'with invalid options' do
          subject do
            begin
              super()
            rescue OptionParser::InvalidOption
              true
            else
              false
            end
          end
          
          let(:args){'install --invalid-option addon-name'}
          
          it 'should throw `OptionParser::InvalidOption` exception' do
            is_expected.to be_truthy
          end
        end
      end
    end
  end
end
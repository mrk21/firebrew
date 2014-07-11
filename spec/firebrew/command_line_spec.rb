require 'spec_helper'

module Firebrew
  describe Firebrew::CommandLine do
    subject do
      CommandLine.new(self.args.split(/\s+/))
    end
    let(:args){''}
    
    context 'when the command was invalid' do
      let(:args){'invalid-command'}
      it { expect{subject}.to raise_error(Firebrew::CommandLineError) }
    end
    
    context 'when the options was invalid' do
      let(:args){'install --invalid-option'}
      it { expect{subject}.to raise_error(Firebrew::CommandLineError) }
    end
    
    describe '#arguments()' do
      subject { super().arguments }
      
      describe 'install command' do
        let(:args){'install addon-name'}
        
        it 'should parse' do
          is_expected.to eq(
            command: :install,
            params: {
              term: 'addon-name'
            },
            config: {}
          )
        end
        
        context 'with options' do
          let(:args){'--base-dir=/path/to/dir install -p default addon-name --profile=test --firefox=/path/to/firefox'}
          
          it 'should parse' do
            is_expected.to eq(
              command: :install,
              params: {
                term: 'addon-name'
              },
              config: {
                base_dir: '/path/to/dir',
                profile: 'test',
                firefox: '/path/to/firefox'
              }
            )
          end
        end
      end
      
      describe 'uninstall command' do
        let(:args){'uninstall addon-name'}
        it 'should parse' do
          is_expected.to eq(
            command: :uninstall,
            params: {
              term: 'addon-name'
            },
            config: {}
          )
        end
      end
      
      describe 'info command' do
        let(:args){'info term'}
        
        it 'should parse' do
          is_expected.to eq(
            command: :info,
            params: {
              term: 'term'
            },
            config: {}
          )
        end
      end
      
      describe 'search command' do
        let(:args){'search term'}
        
        it 'should parse' do
          is_expected.to eq(
            command: :search,
            params: {
              term: 'term'
            },
            config: {}
          )
        end
      end
      
      describe 'list command' do
        let(:args){'list'}
        it 'should parse' do
          is_expected.to eq(
            command: :list,
            params: {},
            config: {}
          )
        end
      end
    end
  end
end

require 'spec_helper'

module Firebrew::Firefox
  describe Command do
    subject do
      Command.new(self.config, self.executer)
    end
    
    let(:config){Firebrew::Runner.default_config}
    let(:executer){Command::Executer.new}
    
    context 'when the indicated firefox command by the `config[:firefox]` not existed' do
      let(:config){super().merge firefox: 'firefox/not/existed/path'}
      it { expect{subject}.to raise_error(Firebrew::FirefoxCommandError) }
    end
    
    context 'when the indicated command by the `config[:firefox]` was not firefox' do
      let(:executer) do
        double('executer', exec: ['Other program', 0])
      end
      it { expect{subject}.to raise_error(Firebrew::FirefoxCommandError) }
      
      describe 'command status' do
        let(:executer) do
          double('executer', exec: ['Fake Mozilla Firefox', 1])
        end
        it { expect{subject}.to raise_error(Firebrew::FirefoxCommandError) }
      end
    end
    
    describe '#version()' do
      subject { super().version }
      let(:executer) do
        double('executer', exec: ['Mozilla Firefox 30.0', 0])
      end
      it { is_expected.to eq('30.0') }
    end
  end
end

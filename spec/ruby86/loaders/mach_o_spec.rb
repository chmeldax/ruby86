require 'spec_helper'

describe Ruby86::Loaders::MachO do
  context 'correct file' do
    subject { described_class.new(path) }
    let(:path) { File.expand_path File.dirname(__FILE__) + './../../fixtures/mach_o/print.out' }

    describe '#load!' do
      it 'runs without error' do
        expect{subject.load!}.to_not raise_error
      end
    end
  end
end

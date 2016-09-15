require 'spec_helper'

describe Ruby86::Loaders::MachO do
  context 'correct file' do
    subject { described_class.new(path, memory) }
    let(:path) { File.expand_path File.dirname(__FILE__) + './../../fixtures/mach_o/print.out' }
    let(:memory) { {} }
    describe '#load!' do
      let(:segments_count) { 4 }
      let(:memory_size) { 4096 + 4096 + 240 }
      it 'runs without error' do
        expect{subject.load!}.to_not raise_error
      end

      it 'load four segments' do
        expect{subject.load!}.to change{subject.segments.count}.from(0).to(segments_count)
      end

      it 'fills memory with correct size' do
        expect{subject.load!}.to change{memory.to_a.count}.from(0).to(memory_size)
      end
    end
  end
end

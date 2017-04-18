require 'spec_helper'

include RuboCop::AST::Sexp

RSpec.describe Rubocopular do

  it 'has a version number' do
    expect(Rubocopular::VERSION).not_to be nil
  end

  describe '.node' do
    it { expect(described_class.node(1)).to eq(s(:int,1)) }
    it { expect(described_class.node('a string')).to eq(s(:send, nil, :a, s(:send, nil, :string))) }
  end

  describe '.test' do
    subject { described_class.test(pattern, code) }

    it { expect(described_class.test('(int _)', '1')).to be_truthy }
    it { expect(described_class.test('(str _)', '""')).to be_truthy }
    it { expect(described_class.test('(str _)', '1')).to be_falsy }

    describe 'capturing' do
      it { expect(described_class.test('(:def $_ _ (send _ ... ) )', 'def a; b.c end')).to eq(:a) }
      it { expect(described_class.test('(:def _ $_ (send _ ... ) )', 'def a; b.c end')).to eq(s(:args)) }
      it { expect(described_class.test('(:def _ _ (send $_ ... ) )', 'def a; b.c end')).to eq(s(:send, nil, :b)) }
      it { expect(described_class.test('(:def _ _ (send _ $... ) )', 'def a; b.c end')).to eq([:c]) }
      it { expect(described_class.test('(:def _ _ (send _ $_ ) )', 'def a; b.c end')).to eq(:c) }
      it { expect(described_class.test('(:def ... (send _ $_ ) )', 'def a; b.c end')).to eq(:c) }
    end

    describe 'capturing' do
      let(:code) { 'def a(param); b.c.d.e.f end' }

      describe 'method name' do
        let(:pattern) { '(:def $_ _args (send (send ...) ... ) )' }
        it { is_expected.to eq  :a }
      end

      describe 'params' do
        let(:pattern) { '(:def _ $_ (send (send ...) ... ) )' }
        it { is_expected.to eq s(:args, s(:arg, :param)) }
      end

      describe 'internal send methods' do
        let(:pattern) { '(:def _method _args (send (send $...) ... ) )' }
        it { is_expected.to eq  [s(:send, s(:send, s(:send, nil, :b), :c), :d), :e] }
      end

      describe 'penultimate method name' do
        let(:pattern) { '(:def _method _args (send (send _ $...) ... ) )' }
        it { is_expected.to eq  [:e] }
      end

      describe '3 levels up' do
        let(:pattern) { '(:def _method _args (send (send (send _ $...) ...) ... ) )' }
        it { is_expected.to eq  [:d] }
      end

      describe 'multiple elements' do
        let(:pattern) { '(:def _method _args (send (send (send (send (send _ $...) ...) $...) ...) ... ) )' }
        it { is_expected.to eq  [[:b],[:d]] }
      end

      describe 'all send stuff' do
        let(:pattern) { '(:def _method _args (send (send (send (send (send _ $...) $...) $...) $...) $... ) )' }
        it { is_expected.to eq [[:b], [:c], [:d], [:e], [:f]] }
      end
    end
  end

  describe '.inspect' do
    it 'works as .test but captures _ and ...' do
      inspect = described_class.inspect('(int _)', 1)
      test    = described_class.test('(int $_)', 1)
      expect(test).to eq inspect
    end

    it { expect(described_class.inspect('(int _)', 1)).to eq 1 }
    it { expect(described_class.inspect('(send ...)', 'a.b')).to eq([s(:send, nil, :a), :b]) }

    shared_examples 'captures' do |result|
      subject(:capture) { described_class.inspect(pattern, source) }
      specify do
        expect(capture).to eq result
      end
    end

    describe 'captures _ and ...' do
      let(:source) { 'def b; a.b end' }
      let(:pattern) { '(:def _method _args (send _ ... ) )' }

      it_behaves_like 'captures', [:b, s(:args), s(:send, nil, :a), [:b]]
    end
  end
end

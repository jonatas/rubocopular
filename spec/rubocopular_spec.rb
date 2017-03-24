require 'spec_helper'

RSpec.describe Rubocopular do

  include RuboCop::AST::Sexp

  it 'has a version number' do
    expect(Rubocopular::VERSION).not_to be nil
  end

  describe '.node' do
    it { expect(described_class.node(1)).to eq(s(:int,1)) }
    it { expect(described_class.node('a string')).to eq(s(:send, nil, :a, s(:send, nil, :string))) }
  end

  describe '.test' do
    it { expect(described_class.test('(int _)', 1)).to be_truthy }
  end

  describe '.inspect' do
    it { expect(described_class.inspect('(int _)', 1)).to eq 1 }
    it { expect(described_class.inspect('(send ...)', 'a.b')).to eq([s(:send, nil, :a), :b]) }
  end

end

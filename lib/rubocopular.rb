require 'rubocopular/version'
require 'rubocop'

module Rubocopular
  def self.node(code)
    RuboCop::ProcessedSource.new(code.to_s, 2.3).ast
  end

  def self.test(pattern, code)
    RuboCop::NodePattern.new(pattern).match(node(code))
  end

  def self.inspect(pattern, code)
    RuboCop::NodePattern.new(pattern.gsub(/(\.{3}|_)/, '$\1')).match(node(code))
  end
end

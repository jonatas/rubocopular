require 'rubocopular/version'
require 'rubocop'
require 'coderay'

module Rubocopular
  def self.node(code)
    RuboCop::ProcessedSource.new(code.to_s, 2.3).ast
  end

  def self.parse_source(path)
    RuboCop::ProcessedSource.new(IO.read(path), 2.3, path)
  end

  def self.test(pattern, code)
    code = node(code) unless code.is_a?(RuboCop::AST::Node)
    RuboCop::NodePattern.new(pattern).match(code)
  end

  def self.inspect(pattern, code)
    RuboCop::NodePattern.new(pattern.gsub(/(\.{3}|_)/, '$\1')).match(node(code))
  end
end

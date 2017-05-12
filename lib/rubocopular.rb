require 'rubocopular/version'
require 'rubocop'
require 'coderay'

module Rubocopular
  def self.node(code)
    RuboCop::ProcessedSource.new(code.to_s, 2.3).ast
  end

  def self.test(pattern, code)
    code = node(code) if code.is_a?(String)
    RuboCop::NodePattern.new(pattern).match(code)
  end

  def self.inspect(pattern, code)
    RuboCop::NodePattern.new(pattern.gsub(/(\.{3}|_)/, '$\1')).match(node(code))
  end
end

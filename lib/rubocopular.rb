require 'rubocopular/version'
require 'rubocop'
require 'parser/current'

module Rubocopular
  def self.node(code)
    buffer = Parser::Source::Buffer.new('')
    buffer.source = code.to_s
    builder = RuboCop::AST::Builder.new
    Parser::CurrentRuby.new(builder).parse(buffer)
  end

  def self.test(pattern, code)
    RuboCop::NodePattern.new(pattern).match(node(code))
  end

  def self.inspect(pattern, code)
    RuboCop::NodePattern.new(pattern.gsub(/(\.{3}|_)/, '$\1')).match(node(code))
  end
end

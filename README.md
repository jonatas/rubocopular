# Rubocopular

It's a small gem to help you debug your RuboCop node patterns.


## Try on console

```bash
git clone git@github.com:jonatas/rubocopular.git
cd rubocopular
bin/setup
```

## Usage of `bin/console`

Try run `bin/console` for an interactive prompt that will allow you to experiment.

The `node` method will allow you to transform your code into `AST`.

```ruby
> Rubocopular.node(1)
=> s(:int, 1)
> Rubocopular.node('1')
=> s(:int, 1)
> Rubocopular.node("'1'")
=> s(:str, "1")
> Rubocopular.node("a = 1")
=> s(:lvasgn, :a,
  s(:int, 1))
> Rubocopular.node("def method ; body end")
=> s(:def, :method,
  s(:args),
  s(:send, nil, :body))
```

If you're using `bin/console` you can also call `node` or `test` directly.

```
> node("a.b.c.d")
=> s(:send,
  s(:send,
    s(:send,
      s(:send, nil, :a), :b), :c), :d)
```

You can also navigate on children nodes:

```ruby
> nodes = Rubocopular.node('class A; a; b; c -> {} end').children.last
=> s(:begin,
  s(:send, nil, :a),
  s(:send, nil, :b),
  s(:send, nil, :c,
    s(:block,
      s(:send, nil, :lambda),
      s(:args), nil)))
> nodes.children.map(&:method_name)
=> [:a, :b, :c]
```

You can test your matchers and inspect them:

```ruby
> Rubocopular.inspect('(send ...)',"a.b.c.d")
=> [s(:send,
  s(:send,
    s(:send, nil, :a), :b), :c), :d]
```

The `inspect` is just wrapping the `_` and `...` to call `.test` method:

```ruby
> Rubocopular.test('(:def _method _args (send (send (send _ $...) ...) ... ) )', 'def a; b.c.d.e.f end')
=> [:d]
> Rubocopular.test('(:def _method _args (send (send (send (send _ $...) ...) ...) ... ) )', 'def a; b.c.d.e.f end')
=> [:c]
> Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) ...) ...) ... ) )', 'def a; b.c.d.e.f end')
=> [[:b], [:c]]
> Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) $...) ...) ... ) )', 'def a; b.c.d.e.f end')
=> [[:b], [:c], [:d]]
> Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) $...) $...) $... ) )', 'def a; b.c.d.e.f end')
=> [[:b], [:c], [:d], [:e], [:f]]
> Rubocopular.test('(:def $_ _args (send (send (send (send (send _ $_) $_) $_) $_) $_ ) )', 'def a; b.c.d.e.f end')
=> [:a, :b, :c, :d, :e, :f]
> Rubocopular.inspect('(:def _ (:args) (send (send (send (send (send _ _) _) _) _) _ ) )', 'def a; b.c.d.e.f end')
=> [:a, nil, :b, :c, :d, :e, :f]
```

Check that the examples uses more `...` than `_` to allow more flexibility on the syntax:

```ruby
> Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) $_) $...) $... ) )', 'def a; b.c.d.e(param).f end')
=> [[:b], [:c], :d, [:e, s(:send, nil, :param)], [:f]]
> Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) $_) $...) $... ) )', 'def a; b.c.d(param).e.f end')
=> nil
Rubocopular.test('(:def _method _args (send (send (send (send (send _ $...) $...) $_) $...) $... ) )', 'def a; b.c.d.e.f end')
=> [[:b], [:c], :d, [:e], [:f]]
```

Keep in mind `...` can be anything and `_` is only one thing.

You can also use `{}` to wrap different nodes

```ruby
> Rubocopular.test('(${def kwbegin} ... (rescue _ $...))','def a ; rescue => e; end')
=> [:def, [s(:resbody, nil,
  s(:lvasgn, :e), nil), nil]]
> Rubocopular.test('(${def kwbegin} ... (rescue _ $...))','begin ; rescue => e; end')
=> [:kwbegin, [s(:resbody, nil,
  s(:lvasgn, :e), nil), nil]]
```

In this case the `...` was used only for `:def` but it still needed.

```ruby
> Rubocopular.test('(${def kwbegin} _ _ (rescue _ $...))','def a ; rescue => e; end')
=> [:def, [s(:resbody, nil,
  s(:lvasgn, :e), nil), nil]]
> Rubocopular.test('(${def kwbegin} _ _ (rescue _ $...))','begin ; rescue => e; end')
=> nil
```

You can remind that `...` is anything and it includes nothing. While `_` is always one thing.

## Usage of `bin/search`

You can also do like a "grep" using `bin/search`:

Trying it in this project:

    $ bin/search '(const ... )' lib/*.rb

It will output something like:

```
lib/rubocopular.rb:5: Rubocopular
lib/rubocopular.rb:7: RuboCop::ProcessedSource
lib/rubocopular.rb:11: RuboCop::ProcessedSource
lib/rubocopular.rb:11: IO
lib/rubocopular.rb:15: RuboCop::AST::Node
lib/rubocopular.rb:16: RuboCop::NodePattern
lib/rubocopular.rb:20: RuboCop::NodePattern
lib/rubocopular.rb:24: RuboCop::AST::Node
```

It prints nodes that matches with the current code:

    $ bin/search '(defs ... )' lib/*.rb

```
lib/rubocopular.rb:6: def self.node(code)
    RuboCop::ProcessedSource.new(code.to_s, 2.3).ast
  end
lib/rubocopular.rb:10: def self.parse_source(path)
    RuboCop::ProcessedSource.new(IO.read(path), 2.3, path)
  end
lib/rubocopular.rb:14: def self.test(pattern, code)
    code = node(code) unless code.is_a?(RuboCop::AST::Node)
    RuboCop::NodePattern.new(pattern).match(code)
  end
lib/rubocopular.rb:19: def self.inspect(pattern, code)
    RuboCop::NodePattern.new(pattern.gsub(/(\.{3}|_)/, '$\1')).match(node(code))
  end
```

## Development

Use `guard` to follow the tests running. 

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonatas/rubocopular. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


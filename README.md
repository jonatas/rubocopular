# Rubocopular

It's a small gem to help you debug your RuboCop node patterns.


## Try on console

```bash
git clone git@github.com:jonatas/rubocopular.git
cd rubocopular
bin/setup
```

## Usage

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
> Rubocopular.node("a.b.c.d")
=> s(:send,
  s(:send,
    s(:send,
      s(:send, nil, :a), :b), :c), :d)
```

You can test your matchers and inspect them:

```ruby
> Rubocopular.inspect('(send ...)',"a.b.c.d")
=> [s(:send,
  s(:send,
    s(:send, nil, :a), :b), :c), :d]
```


## Development

Use `guard` to follow the tests running. 

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubocopular. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


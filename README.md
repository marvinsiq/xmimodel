XmiModel
========

A helper gem for working with XMI Models

## You need
- [Ruby] (http://www.ruby-lang.org)
- [Bundler] (http://gembundler.com)

## Install

execute

```
./install.sh
```

or

```
bundle install
gem build xmimodel.gemspec
gem install ./xmimodel-*.gem
```

# How to Use

Import the *gem* in your application.

```
% irb
>> require 'xmimodel'
```

Create an object of type 'XmiModel' passing the path model
```
>> model = XmiModel.new("model_path.xmi")
```

See all methods available in the documentation
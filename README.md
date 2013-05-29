XmiModel
========

A helper gem for working with XMI Models

# Requirements
You need
- [Ruby] (http://www.ruby-lang.org)
- [Bundler] (http://gembundler.com)

# Installation

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

# Usage

Import the *gem* in your application.

```
% irb
>> require 'xmimodel'
```

Create an object of type 'XmiModel' passing the path model

```
>> model = XmiModel.new("model_path.xmi")
```

See all methods available in the [documentation](http://rubydoc.info/github/marvinsiq/xmimodel/master/frames)

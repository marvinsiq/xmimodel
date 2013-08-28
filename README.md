# XmiModel

A helper gem for working with XMI Models

## Installation

Execute

```
$ gem install xmimodel
```

Or, add this line to your application's Gemfile:

```
gem 'xmimodel'
```

And then execute:

```
$ bundle install
```

To install a local gem execute:

```
$ bundle install
$ gem build xmimodel.gemspec
$ gem install ./xmimodel-*.gem
```
See all versions in [http://rubygems.org/gems/xmimodel](http://rubygems.org/gems/xmimodel)

## Usage

Import the *gem* in your application and create an object of type 'XmiModel' passing the path model.
Example:

```
% irb
> require 'xmimodel'
=> true
> model = XmiModel.new("test/resource/MagicDraw/escola.xml")
=> 'XmiModel MagicDraw UML 9.5 [Packages: 5, Classes: 7]'
> model.classes.first.name
=> "Aluno"
> model.classes[2].package
=> Package[br.escola.domain]
> model.classes.[1].attributes     
=> [Attribute[br.escola.domain.Aluno::matricula], Attribute[br.escola.domain.Aluno::ativo]]
> model.classes[3].full_name
=> "br.escola.domain.Professor"
> model.classes[3].parent   
=> Clazz[br.escola.domain.Pessoa]
> model.classes[6].operations
=> [Operation[br.escola.view.AlunoIncluir::carregarDados]]

```

See all methods available in the <a href="http://rubydoc.info/github/marvinsiq/xmimodel/master/frames" target="_top">documentation</a>.

## Changelog

All changes could be found in [CHANGELOG.md](CHANGELOG.md)

## Documentation
The <a href="http://rubydoc.info/github/marvinsiq/xmimodel/master/frames" target="_top">documentation</a> is available on <a href="http://rubydoc.info/github/marvinsiq/xmimodel/master/frames" target="_top">http://rubydoc.info</a>.

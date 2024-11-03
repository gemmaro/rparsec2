# rparsec Change Log

## Unreleased

## 1.2.0 - 2024-11-04

* Remove runtime type checker and signature.
* Removed `def_mutable` method.
* Enable frozen string literal.
* Split operator table class to file.  `require
  "rparsec/operator_table"` to use it.
* Split functor mixin module to a file.  `require
  "rparsec/functor_mixin"` to use it.
* Move `Parsers` module to `lib/rparsec/parsers.rb`.
* Add `Parser`'s `set_name` instance method.

## 1.1.0 - 2024-11-03

Changes from 1.0:

* Support Ruby 3.1 or later.
* Add documentation.
* Add the BSD license file according to the [rparsec project page](https://web.archive.org/web/20140515214123/https://rubyforge.org/projects/rparsec/) on the archived RubyForge site.

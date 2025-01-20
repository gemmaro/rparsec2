# rparsec Change Log

## Unreleased

## 1.3.0 - 2025-01-20

* Remove unused precedence constants from the failure class and the expected
  class.
* Remove identity monad.
* Remove set-name method of parser class.
* Use data class for token class.
* Remove define-constructor method.
* Rename define-helper filename.
* Remove define-helper for parser class.
* Split parser classes into files.
* Split failures class.

## 1.2.1 - 2024-11-17

This is a maintenance release.

* Update document link in gemspec.

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

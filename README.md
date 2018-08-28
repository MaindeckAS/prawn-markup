# Prawn::Markup

[![Build Status](https://travis-ci.org/puzzle/prawn-markup.svg?branch=master)](https://travis-ci.org/puzzle/prawn-markup)
[![Maintainability](https://api.codeclimate.com/v1/badges/52a462f9d65e33352d4e/maintainability)](https://codeclimate.com/github/puzzle/prawn-markup/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/52a462f9d65e33352d4e/test_coverage)](https://codeclimate.com/github/puzzle/prawn-markup/test_coverage)

Adds simple HTML snippets into [Prawn](http://prawnpdf.org)-generated PDFs. No CSS is supported, all elements are layouted vertically with basic styling options. A major use case for this gem is to include WYSIWYG-generated HTML parts into server-generated PDF documents.

This gem does not and will never convert entire HTML + CSS pages to PDF. Use [wkhtmltopdf](https://wkhtmltopdf.org/) for that.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prawn-markup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prawn-markup

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/puzzle/prawn-markup. For pull requests, add specs, make sure all of them pass and fix all rubocop issues.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Prawn::Markup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/puzzle/prawn-markup/blob/master/CODE_OF_CONDUCT.md).
